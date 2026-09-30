package me.pulkitagarwal.in_app_update_flutter

import android.app.Activity
import android.content.Intent
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.ActivityResult
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class InAppUpdateFlutterPlugin internal constructor(
    private val createAppUpdateManager: (Activity) -> AppUpdateManager,
) : FlutterPlugin, MethodCallHandler, ActivityAware,
    EventChannel.StreamHandler, PluginRegistry.ActivityResultListener {

    constructor() : this({ activity -> AppUpdateManagerFactory.create(activity) })

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var activity: Activity? = null
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var appUpdateManager: AppUpdateManager? = null
    private var eventSink: EventChannel.EventSink? = null
    private var installStateListener: InstallStateUpdatedListener? = null
    private var pendingResult: Result? = null

    companion object {
        private const val REQUEST_CODE_IMMEDIATE = 1001
        private const val REQUEST_CODE_FLEXIBLE = 1002
    }

    // region FlutterPlugin

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "in_app_update_flutter")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "in_app_update_flutter/installStateAndroid")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    // endregion

    // region ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
        appUpdateManager = createAppUpdateManager(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        unregisterActivityListener()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
        appUpdateManager = createAppUpdateManager(binding.activity)
    }

    override fun onDetachedFromActivity() {
        unregisterActivityListener()
    }

    private fun unregisterActivityListener() {
        activityPluginBinding?.removeActivityResultListener(this)
        activityPluginBinding = null
        activity = null
        appUpdateManager = null
    }

    // endregion

    // region MethodCallHandler

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "checkForUpdateAndroid" -> handleCheckForUpdate(result)
            "startImmediateUpdateAndroid" -> handleStartUpdate(call, result, AppUpdateType.IMMEDIATE)
            "startFlexibleUpdateAndroid" -> handleStartUpdate(call, result, AppUpdateType.FLEXIBLE)
            "completeUpdateAndroid" -> handleCompleteUpdate(result)
            else -> result.notImplemented()
        }
    }

    private fun handleCheckForUpdate(result: Result) {
        val manager = appUpdateManager
        if (manager == null) {
            result.error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
            return
        }

        manager.appUpdateInfo.addOnSuccessListener { info ->
            result.success(serializeAppUpdateInfo(info))
        }.addOnFailureListener { e ->
            result.error("CHECK_UPDATE_FAILED", "Failed to check for updates", e.localizedMessage)
        }
    }

    private fun handleStartUpdate(call: MethodCall, result: Result, updateType: Int) {
        val currentActivity = activity
        val manager = appUpdateManager

        if (currentActivity == null || manager == null) {
            result.error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
            return
        }

        if (pendingResult != null) {
            result.error("ALREADY_RUNNING", "An update flow is already in progress", null)
            return
        }

        pendingResult = result

        val allowAssetPackDeletion = call.argument<Boolean>("allowAssetPackDeletion") ?: false

        manager.appUpdateInfo.addOnSuccessListener { info ->
            if (info.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE &&
                info.isUpdateTypeAllowed(updateType)
            ) {
                startUpdateFlow(manager, info, currentActivity, updateType, allowAssetPackDeletion)
            } else if (info.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS) {
                startUpdateFlow(manager, info, currentActivity, updateType, allowAssetPackDeletion)
            } else {
                pendingResult?.error(
                    "UPDATE_NOT_AVAILABLE",
                    "No update available or update type not allowed",
                    null
                )
                pendingResult = null
            }
        }.addOnFailureListener { e ->
            pendingResult?.error("CHECK_UPDATE_FAILED", "Failed to check for updates", e.localizedMessage)
            pendingResult = null
        }
    }

    /**
     * Starts the Play update flow. [pendingResult] is completed later in [onActivityResult], so it
     * is failed here if the flow never starts: either Play Core returns false (for example when
     * the update type is not allowed) or it throws while launching the update Activity.
     */
    private fun startUpdateFlow(
        manager: AppUpdateManager,
        info: AppUpdateInfo,
        activity: Activity,
        updateType: Int,
        allowAssetPackDeletion: Boolean,
    ) {
        val options = AppUpdateOptions.newBuilder(updateType)
            .setAllowAssetPackDeletion(allowAssetPackDeletion)
            .build()

        val requestCode = if (updateType == AppUpdateType.IMMEDIATE) {
            REQUEST_CODE_IMMEDIATE
        } else {
            REQUEST_CODE_FLEXIBLE
        }

        val started = try {
            manager.startUpdateFlowForResult(info, activity, options, requestCode)
        } catch (e: Exception) {
            pendingResult?.error("START_UPDATE_FAILED", "Failed to start the update flow", e.localizedMessage)
            pendingResult = null
            return
        }

        if (!started) {
            pendingResult?.error("UPDATE_NOT_STARTED", "The update flow could not be started", null)
            pendingResult = null
        }
    }

    private fun handleCompleteUpdate(result: Result) {
        val manager = appUpdateManager
        if (manager == null) {
            result.error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
            return
        }

        manager.completeUpdate().addOnSuccessListener {
            result.success(null)
        }.addOnFailureListener { e ->
            result.error("COMPLETE_UPDATE_FAILED", "Failed to complete update", e.localizedMessage)
        }
    }

    private fun serializeAppUpdateInfo(info: AppUpdateInfo): Map<String, Any?> {
        return mapOf(
            "updateAvailability" to info.updateAvailability(),
            "availableVersionCode" to if (info.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE) {
                info.availableVersionCode()
            } else {
                null
            },
            "updatePriority" to info.updatePriority(),
            "clientVersionStalenessDays" to info.clientVersionStalenessDays(),
            "isImmediateUpdateAllowed" to info.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE),
            "isFlexibleUpdateAllowed" to info.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE),
            "installStatus" to info.installStatus(),
        )
    }

    // endregion

    // region EventChannel.StreamHandler

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        installStateListener = InstallStateUpdatedListener { state ->
            eventSink?.success(
                mapOf(
                    "status" to state.installStatus(),
                    "bytesDownloaded" to state.bytesDownloaded(),
                    "totalBytesToDownload" to state.totalBytesToDownload(),
                )
            )
        }
        appUpdateManager?.registerListener(installStateListener!!)
    }

    override fun onCancel(arguments: Any?) {
        installStateListener?.let { appUpdateManager?.unregisterListener(it) }
        installStateListener = null
        eventSink = null
    }

    // endregion

    // region ActivityResultListener

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE_IMMEDIATE && requestCode != REQUEST_CODE_FLEXIBLE) {
            return false
        }

        val resultValue = when (resultCode) {
            Activity.RESULT_OK -> 0 // success
            Activity.RESULT_CANCELED -> 1 // userCanceled
            ActivityResult.RESULT_IN_APP_UPDATE_FAILED -> 2 // inAppUpdateFailed
            else -> 2 // inAppUpdateFailed
        }

        pendingResult?.success(resultValue)
        pendingResult = null
        return true
    }

    // endregion
}
