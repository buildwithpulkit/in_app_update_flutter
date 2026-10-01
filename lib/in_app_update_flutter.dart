import 'package:in_app_update_flutter/src/models/models.dart';
import 'package:in_app_update_flutter/src/platform_interface/in_app_update_flutter_platform_interface.dart';

export 'package:in_app_update_flutter/src/models/models.dart';

/// A Flutter plugin for in-app updates.
///
/// On iOS, use [showUpdateForIos] to present the App Store product page
/// using StoreKit.
///
/// On Android, use [checkUpdateAndroid] to check for updates via Google Play's
/// In-App Updates API, then [startImmediateUpdateAndroid] or
/// [startFlexibleUpdateAndroid] to start the update flow.
class InAppUpdateFlutter {
  /// iOS: Shows the App Store product page overlay via StoreKit.
  ///
  /// [appStoreId] is the numeric App Store ID of your app
  /// (found in your App Store Connect URL).
  Future<void> showUpdateForIos({required String appStoreId}) {
    return InAppUpdateFlutterPlatform.instance
        .showUpdateForIos(appStoreId: appStoreId);
  }

  /// Android: Checks whether an in-app update is available via Play Core.
  ///
  /// Returns an [AppUpdateInfoAndroid] containing update metadata such as
  /// availability, version code, priority, staleness, and allowed update types.
  Future<AppUpdateInfoAndroid> checkUpdateAndroid() {
    return InAppUpdateFlutterPlatform.instance.checkUpdateAndroid();
  }

  /// Android: Starts the immediate (full-screen, blocking) update flow.
  ///
  /// The user must accept the update to continue using the app. If the user
  /// closes the update screen, [UpdateResultAndroid.userCanceled] is returned.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  Future<UpdateResultAndroid> startImmediateUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) {
    return InAppUpdateFlutterPlatform.instance.startImmediateUpdateAndroid(
      allowAssetPackDeletion: allowAssetPackDeletion,
    );
  }

  /// Android: Starts the flexible (background download) update flow.
  ///
  /// The update downloads in the background while the user continues
  /// using the app. Listen to [installStateStreamAndroid] for download
  /// progress, and call [completeUpdateAndroid] when the download is complete.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  Future<UpdateResultAndroid> startFlexibleUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) {
    return InAppUpdateFlutterPlatform.instance.startFlexibleUpdateAndroid(
      allowAssetPackDeletion: allowAssetPackDeletion,
    );
  }

  /// Android: Completes a flexible update by triggering an app restart.
  ///
  /// Call this after [installStateStreamAndroid] reports
  /// [InstallStatusAndroid.downloaded].
  Future<void> completeUpdateAndroid() {
    return InAppUpdateFlutterPlatform.instance.completeUpdateAndroid();
  }

  /// Android: A stream of install state changes during a flexible update.
  ///
  /// Emits [InstallStateAndroid] events with download progress and status.
  Stream<InstallStateAndroid> get installStateStreamAndroid {
    return InAppUpdateFlutterPlatform.instance.installStateStreamAndroid;
  }
}
