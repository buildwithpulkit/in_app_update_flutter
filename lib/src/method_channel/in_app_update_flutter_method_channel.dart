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
  Future<AppUpdateInfoIos> checkUpdateIos({String? region}) async {
    final result = await _methodChannel.invokeMapMethod<String, dynamic>(
      'checkUpdateIos',
      region != null ? {'region': region} : null,
    );
    return AppUpdateInfoIos.fromMap(result ?? const {});
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
  Stream<InstallStateAndroid> get installStateStreamAndroid {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return InstallStateAndroid.fromMap(
        Map<String, dynamic>.from(event as Map),
      );
    });
  }
}
