import 'package:flutter/services.dart';
import 'package:in_app_update_flutter/src/models/models.dart';
import 'package:in_app_update_flutter/src/platform_interface/in_app_update_flutter_platform_interface.dart';

/// An implementation of [InAppUpdateFlutterPlatform] that uses method channels.
class MethodChannelInAppUpdateFlutter extends InAppUpdateFlutterPlatform {
  /// The method channel used to interact with the native platform.
  static const MethodChannel _methodChannel = MethodChannel(
    'in_app_update_flutter',
  );

  /// The event channel for receiving install state updates during flexible updates.
  static const EventChannel _eventChannel = EventChannel(
    'in_app_update_flutter/installStateAndroid',
  );

  /// The single stream shared by every listener of [installStateStreamAndroid].
  ///
  /// Each [EventChannel.receiveBroadcastStream] call creates a stream that
  /// takes over the channel's message handler when listened to and clears it
  /// when cancelled, so creating more than one would leave all but the newest
  /// listener without events. Sharing one broadcast stream sends `listen` to
  /// the platform for the first listener and `cancel` after the last one.
  static final Stream<InstallStateAndroid> _installStateStream =
      _eventChannel.receiveBroadcastStream().map((event) {
    return InstallStateAndroid.fromMap(
      Map<String, dynamic>.from(event as Map),
    );
  });

  @override
  @Deprecated(
    'Use showUpdateForIos() on iOS or checkUpdateAndroid() + '
    'startImmediateUpdateAndroid()/startFlexibleUpdateAndroid() on Android',
  )
  Future<void> showUpdate({required String appStoreId}) async {
    await _methodChannel.invokeMethod('showStoreUpdateIos', {
      'appStoreId': appStoreId,
    });
  }

  @override
  Future<void> showUpdateForIos({required String appStoreId}) async {
    await _methodChannel.invokeMethod('showStoreUpdateIos', {
      'appStoreId': appStoreId,
    });
  }

  @override
  Future<AppUpdateInfoAndroid> checkUpdateAndroid() async {
    final result = await _methodChannel.invokeMapMethod<String, dynamic>(
      'checkForUpdateAndroid',
    );
    return AppUpdateInfoAndroid.fromMap(result!);
  }

  @override
  Future<UpdateResultAndroid> startImmediateUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) async {
    final result = await _methodChannel.invokeMethod<int>(
      'startImmediateUpdateAndroid',
      {'allowAssetPackDeletion': allowAssetPackDeletion},
    );
    return UpdateResultAndroid.fromValue(result!);
  }

  @override
  Future<UpdateResultAndroid> startFlexibleUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) async {
    final result = await _methodChannel.invokeMethod<int>(
      'startFlexibleUpdateAndroid',
      {'allowAssetPackDeletion': allowAssetPackDeletion},
    );
    return UpdateResultAndroid.fromValue(result!);
  }

  @override
  Future<void> completeUpdateAndroid() async {
    await _methodChannel.invokeMethod<void>('completeUpdateAndroid');
  }

  @override
  Stream<InstallStateAndroid> get installStateStreamAndroid =>
      _installStateStream;
}
