import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

void main() {
  group('InstallStatusAndroid.fromPlayCoreValue', () {
    /// The full Play Core `InstallStatus` constant table.
    ///
    /// See https://developer.android.com/reference/com/google/android/play/core/install/model/InstallStatus
    const playCoreConstants = <int, InstallStatusAndroid>{
      0: InstallStatusAndroid.unknown,
      1: InstallStatusAndroid.pending,
      2: InstallStatusAndroid.downloading,
      3: InstallStatusAndroid.installing,
      4: InstallStatusAndroid.installed,
      5: InstallStatusAndroid.failed,
      6: InstallStatusAndroid.canceled,
      11: InstallStatusAndroid.downloaded,
    };

    playCoreConstants.forEach((value, expected) {
      test('maps $value to $expected', () {
        expect(InstallStatusAndroid.fromPlayCoreValue(value), expected);
      });
    });

    test('covers every enum member', () {
      expect(
        playCoreConstants.values.toSet(),
        InstallStatusAndroid.values.toSet(),
      );
    });

    test('maps REQUIRES_UI_INTENT (10) to unknown', () {
      expect(
        InstallStatusAndroid.fromPlayCoreValue(10),
        InstallStatusAndroid.unknown,
      );
    });

    test('maps unrecognised values to unknown', () {
      for (final value in [-1, 7, 8, 9, 12, 99]) {
        expect(
          InstallStatusAndroid.fromPlayCoreValue(value),
          InstallStatusAndroid.unknown,
          reason: '$value should not map to a known status',
        );
      }
    });
  });
}
