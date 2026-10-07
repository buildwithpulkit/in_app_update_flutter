/// Contains information about an available App Store update on iOS.
///
/// Returned by [InAppUpdateFlutter.checkUpdateIos].
class AppUpdateInfoIos {
  /// Whether the App Store version is newer than the installed version.
  final bool isUpdateAvailable;

  /// The version currently published on the App Store.
  final String storeVersion;

  /// The version of the installed app (`CFBundleShortVersionString`).
  final String installedVersion;

  const AppUpdateInfoIos({
    required this.isUpdateAvailable,
    required this.storeVersion,
    required this.installedVersion,
  });

  /// Creates an [AppUpdateInfoIos] from a map received via the method channel.
  factory AppUpdateInfoIos.fromMap(Map<String, dynamic> map) {
    return AppUpdateInfoIos(
      isUpdateAvailable: map['isUpdateAvailable'] as bool,
      storeVersion: map['storeVersion'] as String,
      installedVersion: map['installedVersion'] as String,
    );
  }

  @override
  String toString() {
    return 'AppUpdateInfoIos('
        'isUpdateAvailable: $isUpdateAvailable, '
        'storeVersion: $storeVersion, '
        'installedVersion: $installedVersion)';
  }
}
