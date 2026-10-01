import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:in_app_update_flutter/src/method_channel/in_app_update_flutter_method_channel.dart';
import 'package:in_app_update_flutter/src/models/models.dart';

/// The platform interface for the `in_app_update_flutter` plugin.
///
/// This class defines the API that platform-specific implementations
/// must implement. It uses the [PlatformInterface] pattern to ensure
/// safe extension and prevent accidental breaking changes.
abstract class InAppUpdateFlutterPlatform extends PlatformInterface {
  /// Constructs an InAppUpdateFlutterPlatform.
  InAppUpdateFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static InAppUpdateFlutterPlatform _instance =
      MethodChannelInAppUpdateFlutter();

  /// The default instance of [InAppUpdateFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelInAppUpdateFlutter].
  static InAppUpdateFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InAppUpdateFlutterPlatform] when
  /// they register themselves.
  static set instance(InAppUpdateFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Shows the platform-specific in-app update UI.
  ///
  /// On iOS, this presents the App Store product page using StoreKit.
  /// [appStoreId] is the numeric App Store ID of your app.
  @Deprecated(
    'Use showUpdateForIos() on iOS or checkUpdateAndroid() + '
    'startImmediateUpdateAndroid()/startFlexibleUpdateAndroid() on Android',
  )
  Future<void> showUpdate({required String appStoreId}) {
    throw UnimplementedError('showUpdate() has not been implemented.');
  }

  /// iOS: Shows the App Store product page overlay via StoreKit.
  ///
  /// [appStoreId] is the numeric App Store ID of your app
  /// (found in your App Store Connect URL).
  Future<void> showUpdateForIos({required String appStoreId}) {
    throw UnimplementedError('showUpdateForIos() has not been implemented.');
  }

  /// iOS: Checks whether an update is available via the iTunes Lookup API.
  ///
  /// Queries the App Store for the latest published version and compares it
  /// against the currently installed version. The lookup is scoped to the
  /// device's region setting (`Locale.current`) by default.
  ///
  /// Pass [region] (an ISO 3166-1 alpha-2 code, e.g. `'us'`, `'gb'`) to target a
  /// specific App Store region instead — useful when the device region differs
  /// from the storefront the app is published in.
  Future<AppUpdateInfoIos> checkUpdateIos({String? region}) {
    throw UnimplementedError('checkUpdateIos() has not been implemented.');
  }

  /// Android: Checks whether an in-app update is available via Play Core.
  ///
  /// Returns an [AppUpdateInfoAndroid] containing update metadata such as
  /// availability, version code, priority, staleness, and allowed update types.
  Future<AppUpdateInfoAndroid> checkUpdateAndroid() {
    throw UnimplementedError('checkUpdateAndroid() has not been implemented.');
  }

  /// Android: Starts the immediate (full-screen, blocking) update flow.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  Future<UpdateResultAndroid> startImmediateUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) {
    throw UnimplementedError(
      'startImmediateUpdateAndroid() has not been implemented.',
    );
  }

  /// Android: Starts the flexible (background download) update flow.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  ///
  /// Listen to [installStateStreamAndroid] for download progress.
  /// Call [completeUpdateAndroid] when the download is complete.
  Future<UpdateResultAndroid> startFlexibleUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) {
    throw UnimplementedError(
      'startFlexibleUpdateAndroid() has not been implemented.',
    );
  }

  /// Android: Completes a flexible update by triggering an app restart.
  ///
  /// Call this after [installStateStreamAndroid] reports
  /// [InstallStatusAndroid.downloaded].
  Future<void> completeUpdateAndroid() {
    throw UnimplementedError(
      'completeUpdateAndroid() has not been implemented.',
    );
  }

  /// Android: A stream of install state changes during a flexible update.
  ///
  /// Emits [InstallStateAndroid] events with download progress and status.
  Stream<InstallStateAndroid> get installStateStreamAndroid {
    throw UnimplementedError(
      'installStateStreamAndroid has not been implemented.',
    );
  }
}
