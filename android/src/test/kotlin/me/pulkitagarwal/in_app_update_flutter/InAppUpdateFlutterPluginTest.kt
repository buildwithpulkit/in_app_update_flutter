package me.pulkitagarwal.in_app_update_flutter

import android.app.Activity
import android.content.IntentSender
import com.google.android.gms.tasks.OnSuccessListener
import com.google.android.gms.tasks.Task
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import org.mockito.ArgumentMatchers.anyInt
import org.mockito.Mockito

internal class InAppUpdateFlutterPluginTest {
    private val activity: Activity = Mockito.mock(Activity::class.java)
    private val manager: AppUpdateManager = Mockito.mock(AppUpdateManager::class.java)

    /** Creates a plugin attached to a mock activity, backed by [manager]. */
    private fun attachedPlugin(): InAppUpdateFlutterPlugin {
        val binding = Mockito.mock(ActivityPluginBinding::class.java)
        Mockito.`when`(binding.activity).thenReturn(activity)
        val plugin = InAppUpdateFlutterPlugin { manager }
        plugin.onAttachedToActivity(binding)
        return plugin
    }

    /** Makes [AppUpdateManager.getAppUpdateInfo] succeed immediately with [info]. */
    @Suppress("UNCHECKED_CAST")
    private fun givenAppUpdateInfo(info: AppUpdateInfo) {
        val task = Mockito.mock(Task::class.java) as Task<AppUpdateInfo>
        Mockito.`when`(task.addOnSuccessListener(Mockito.any())).thenAnswer { invocation ->
            (invocation.arguments[0] as OnSuccessListener<AppUpdateInfo>).onSuccess(info)
            task
        }
        Mockito.`when`(task.addOnFailureListener(Mockito.any())).thenReturn(task)
        Mockito.`when`(manager.appUpdateInfo).thenReturn(task)
    }

    private fun appUpdateInfo(availability: Int): AppUpdateInfo {
        val info = Mockito.mock(AppUpdateInfo::class.java)
        Mockito.`when`(info.updateAvailability()).thenReturn(availability)
        Mockito.`when`(info.isUpdateTypeAllowed(anyInt())).thenReturn(true)
        return info
    }

    private fun startUpdateFlowForResult(info: AppUpdateInfo) =
        manager.startUpdateFlowForResult(
            Mockito.eq(info),
            Mockito.eq(activity),
            Mockito.any(AppUpdateOptions::class.java),
            anyInt(),
        )

    private fun startCall(method: String) =
        MethodCall(method, mapOf("allowAssetPackDeletion" to false))

    @Test
    fun startFlexibleUpdateAndroid_whenFlowNotStarted_returnsErrorAndAllowsRetry() {
        val plugin = attachedPlugin()
        val info = appUpdateInfo(UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS)
        givenAppUpdateInfo(info)
        Mockito.`when`(startUpdateFlowForResult(info)).thenReturn(false)

        val firstResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(startCall("startFlexibleUpdateAndroid"), firstResult)

        Mockito.verify(firstResult)
            .error("UPDATE_NOT_STARTED", "The update flow could not be started", null)
        Mockito.verifyNoMoreInteractions(firstResult)

        val secondResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(startCall("startFlexibleUpdateAndroid"), secondResult)

        Mockito.verify(secondResult)
            .error("UPDATE_NOT_STARTED", "The update flow could not be started", null)
    }

    @Test
    fun startImmediateUpdateAndroid_whenLaunchThrows_returnsErrorAndAllowsRetry() {
        val plugin = attachedPlugin()
        val info = appUpdateInfo(UpdateAvailability.UPDATE_AVAILABLE)
        givenAppUpdateInfo(info)
        val exception = Mockito.mock(IntentSender.SendIntentException::class.java)
        Mockito.`when`(exception.localizedMessage).thenReturn("launch failed")
        Mockito.`when`(startUpdateFlowForResult(info)).thenThrow(exception)

        val firstResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(startCall("startImmediateUpdateAndroid"), firstResult)

        Mockito.verify(firstResult)
            .error("START_UPDATE_FAILED", "Failed to start the update flow", "launch failed")
        Mockito.verifyNoMoreInteractions(firstResult)

        val secondResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(startCall("startImmediateUpdateAndroid"), secondResult)

        Mockito.verify(secondResult)
            .error("START_UPDATE_FAILED", "Failed to start the update flow", "launch failed")
    }

    @Test
    fun startImmediateUpdateAndroid_whenFlowStarted_completesOnActivityResult() {
        val plugin = attachedPlugin()
        val info = appUpdateInfo(UpdateAvailability.UPDATE_AVAILABLE)
        givenAppUpdateInfo(info)
        Mockito.`when`(startUpdateFlowForResult(info)).thenReturn(true)

        val result: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(startCall("startImmediateUpdateAndroid"), result)

        Mockito.verifyNoInteractions(result)

        plugin.onActivityResult(1001, Activity.RESULT_CANCELED, null)

        Mockito.verify(result).success(1)
        Mockito.verifyNoMoreInteractions(result)
        Mockito.verify(manager).startUpdateFlowForResult(
            Mockito.eq(info),
            Mockito.eq(activity),
            Mockito.argThat<AppUpdateOptions> { it.appUpdateType() == AppUpdateType.IMMEDIATE },
            Mockito.eq(1001),
        )
    }

    @Test
    fun onMethodCall_checkForUpdateAndroid_withoutActivity_returnsError() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("checkForUpdateAndroid", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
    }

    @Test
    fun onMethodCall_startImmediateUpdateAndroid_withoutActivity_returnsError() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("startImmediateUpdateAndroid", mapOf("allowAssetPackDeletion" to false))
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
    }

    @Test
    fun onMethodCall_startFlexibleUpdateAndroid_withoutActivity_returnsError() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("startFlexibleUpdateAndroid", mapOf("allowAssetPackDeletion" to false))
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
    }

    @Test
    fun onMethodCall_completeUpdateAndroid_withoutActivity_returnsError() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("completeUpdateAndroid", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
    }

    @Test
    fun onMethodCall_unknownMethod_returnsNotImplemented() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("unknownMethod", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
    }

    @Test
    fun onMethodCall_showStoreUpdateIos_returnsNotImplemented() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("showStoreUpdateIos", mapOf("appStoreId" to "544007664"))
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
    }
}
