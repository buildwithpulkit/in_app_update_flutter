/// Information about an iOS app update retrieved from the App Store.
class AppUpdateInfoIos {
  /// The latest version available on the App Store.
  final String storeVersion;

  /// The currently installed version of the app.
  final String installedVersion;

  /// Whether an update is available (store version > installed version).
  final bool updateAvailable;

  /// The bundle ID used to look up the App Store listing.
  final String bundleId;

  const AppUpdateInfoIos({
    required this.storeVersion,
    required this.installedVersion,
    required this.updateAvailable,
    required this.bundleId,
  });

  /// Creates an [AppUpdateInfoIos] from a platform channel map.
  factory AppUpdateInfoIos.fromMap(Map<String, dynamic> map) {
    return AppUpdateInfoIos(
      storeVersion: map['storeVersion'] as String? ?? '',
      installedVersion: map['installedVersion'] as String? ?? '',
      updateAvailable: map['updateAvailable'] as bool? ?? false,
      bundleId: map['bundleId'] as String? ?? '',
    );
  }

  @override
  String toString() =>
      'AppUpdateInfoIos(bundleId: $bundleId, installed: $installedVersion, '
      'store: $storeVersion, updateAvailable: $updateAvailable)';
}
