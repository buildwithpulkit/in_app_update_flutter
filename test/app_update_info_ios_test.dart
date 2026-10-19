import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

void main() {
  group('UpdateAvailabilityIos.fromChannelValue', () {
    const channelValues = {
      'updateAvailable': UpdateAvailabilityIos.updateAvailable,
      'updateNotAvailable': UpdateAvailabilityIos.updateNotAvailable,
      'installedNewer': UpdateAvailabilityIos.installedNewer,
      'updateIncompatible': UpdateAvailabilityIos.updateIncompatible,
    };

    channelValues.forEach((value, expected) {
      test('maps $value to $expected', () {
        expect(UpdateAvailabilityIos.fromChannelValue(value), expected);
      });
    });

    test('covers every enum value', () {
      expect(
        channelValues.values.toSet(),
        UpdateAvailabilityIos.values.toSet(),
      );
    });

    test('throws ArgumentError for unrecognized values', () {
      expect(
        () => UpdateAvailabilityIos.fromChannelValue('unknown'),
        throwsArgumentError,
      );
    });
  });

  group('AppUpdateInfoIos.fromMap', () {
    Map<String, dynamic> map(String availability, {String? minimumOs}) => {
          'updateAvailability': availability,
          'installedVersion': '2.1.0',
          'storeVersion': '2.2',
          'appStoreId': '544007664',
          'storeUrl': 'https://apps.apple.com/in/app/id544007664',
          'country': 'in',
          'minimumOsVersion': minimumOs,
        };

    test('decodes every field', () {
      final info = AppUpdateInfoIos.fromMap(
        map('updateAvailable', minimumOs: '15.0'),
      );

      expect(info.updateAvailability, UpdateAvailabilityIos.updateAvailable);
      expect(info.installedVersion, '2.1.0');
      expect(info.storeVersion, '2.2');
      expect(info.appStoreId, '544007664');
      expect(info.storeUrl, 'https://apps.apple.com/in/app/id544007664');
      expect(info.country, 'in');
      expect(info.minimumOsVersion, '15.0');
    });

    test('decodes a null minimumOsVersion', () {
      final info = AppUpdateInfoIos.fromMap(map('installedNewer'));
      expect(info.minimumOsVersion, isNull);
    });

    for (final value in UpdateAvailabilityIos.values) {
      test('decodes updateAvailability ${value.name}', () {
        final info = AppUpdateInfoIos.fromMap(map(value.name));
        expect(info.updateAvailability, value);
      });
    }
  });
}
