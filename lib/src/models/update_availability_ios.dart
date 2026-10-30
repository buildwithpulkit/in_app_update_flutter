/// Represents the availability of an App Store update on iOS.
///
/// Computed by comparing the installed version with the App Store version
/// returned by Apple's iTunes Lookup endpoint.
enum UpdateAvailabilityIos {
  /// The App Store version is newer than the installed version, and this
  /// device's iOS meets the update's `minimumOsVersion`.
  updateAvailable,

  /// The installed version is the same as the App Store version.
  updateNotAvailable,

  /// The installed version is newer than the App Store version, for example
  /// a local Xcode or TestFlight build.
  installedNewer,

  /// The App Store version is newer, but this device's iOS is below the
  /// update's `minimumOsVersion`.
  updateIncompatible;

  /// Creates an [UpdateAvailabilityIos] from the method channel value.
  ///
  /// Throws an [ArgumentError] for an unrecognized value.
  static UpdateAvailabilityIos fromChannelValue(String value) {
    return switch (value) {
      'updateAvailable' => UpdateAvailabilityIos.updateAvailable,
      'updateNotAvailable' => UpdateAvailabilityIos.updateNotAvailable,
      'installedNewer' => UpdateAvailabilityIos.installedNewer,
      'updateIncompatible' => UpdateAvailabilityIos.updateIncompatible,
      _ => throw ArgumentError.value(
        value,
        'value',
        'Unknown UpdateAvailabilityIos value',
      ),
    };
  }
}
