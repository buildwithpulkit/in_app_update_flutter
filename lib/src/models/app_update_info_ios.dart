import 'package:in_app_update_flutter/src/models/update_availability_ios.dart';

/// Contains information about an App Store update on iOS.
///
/// Returned by [InAppUpdateFlutter.checkUpdateIos].
class AppUpdateInfoIos {
  /// The availability of an update.
  final UpdateAvailabilityIos updateAvailability;

  /// The installed version (`CFBundleShortVersionString`), for example `"2.1.0"`.
  final String installedVersion;

  /// The version currently on the App Store, for example `"2.2.0"`.
  final String storeVersion;

  /// The numeric App Store ID (Apple's `trackId`), ready to pass to
  /// [InAppUpdateFlutter.showUpdateForIos].
  final String appStoreId;

  /// The App Store product page URL (Apple's `trackViewUrl`), exactly as
  /// returned.
  final String storeUrl;

  /// The lowercase ISO 3166-1 alpha-2 storefront country used for the lookup,
  /// for example `"in"`.
  final String country;

  /// The minimum iOS version the App Store version requires, or `null` if
  /// Apple's value is missing or not a numeric version.
  final String? minimumOsVersion;

  const AppUpdateInfoIos({
    required this.updateAvailability,
    required this.installedVersion,
    required this.storeVersion,
    required this.appStoreId,
    required this.storeUrl,
    required this.country,
    this.minimumOsVersion,
  });

  /// Creates an [AppUpdateInfoIos] from a map received via the method channel.
  factory AppUpdateInfoIos.fromMap(Map<String, dynamic> map) {
    return AppUpdateInfoIos(
      updateAvailability: UpdateAvailabilityIos.fromChannelValue(
        map['updateAvailability'] as String,
      ),
      installedVersion: map['installedVersion'] as String,
      storeVersion: map['storeVersion'] as String,
      appStoreId: map['appStoreId'] as String,
      storeUrl: map['storeUrl'] as String,
      country: map['country'] as String,
      minimumOsVersion: map['minimumOsVersion'] as String?,
    );
  }

  @override
  String toString() {
    return 'AppUpdateInfoIos('
        'updateAvailability: $updateAvailability, '
        'installedVersion: $installedVersion, '
        'storeVersion: $storeVersion, '
        'appStoreId: $appStoreId, '
        'storeUrl: $storeUrl, '
        'country: $country, '
        'minimumOsVersion: $minimumOsVersion)';
  }
}
