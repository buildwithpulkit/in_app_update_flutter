/// Represents the install status of an in-app update on Android.
///
/// Maps directly to Play Core's `InstallStatus` constants.
enum InstallStatusAndroid {
  /// Install status is unknown.
  unknown,

  /// The update is pending and will be downloaded soon.
  pending,

  /// The update is currently being downloaded.
  downloading,

  /// The update has been downloaded and is ready to be installed.
  downloaded,

  /// The update is currently being installed.
  installing,

  /// The update has been installed successfully.
  installed,

  /// The update has failed.
  failed,

  /// The update has been canceled by the user.
  canceled;

  /// Creates an [InstallStatusAndroid] from a Play Core integer value.
  ///
  /// Play Core constants (non-sequential):
  /// - 0: UNKNOWN
  /// - 1: PENDING
  /// - 2: DOWNLOADING
  /// - 3: INSTALLING
  /// - 4: INSTALLED
  /// - 5: FAILED
  /// - 6: CANCELED
  /// - 11: DOWNLOADED
  ///
  /// 10 (REQUIRES_UI_INTENT) has no enum member and maps to [unknown], as does
  /// any other unrecognised value.
  static InstallStatusAndroid fromPlayCoreValue(int value) {
    return switch (value) {
      1 => InstallStatusAndroid.pending,
      2 => InstallStatusAndroid.downloading,
      3 => InstallStatusAndroid.installing,
      4 => InstallStatusAndroid.installed,
      5 => InstallStatusAndroid.failed,
      6 => InstallStatusAndroid.canceled,
      11 => InstallStatusAndroid.downloaded,
      _ => InstallStatusAndroid.unknown,
    };
  }
}
