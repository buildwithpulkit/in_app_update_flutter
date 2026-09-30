import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

void main() {
  group('InstallStatusAndroid.fromPlayCoreValue', () {
    // Values from Play Core's InstallStatus:
    // https://developer.android.com/reference/com/google/android/play/core/install/model/InstallStatus
    const playCoreValues = {
      0: InstallStatusAndroid.unknown,
      1: InstallStatusAndroid.pending,
      2: InstallStatusAndroid.downloading,
      3: InstallStatusAndroid.installing,
      4: InstallStatusAndroid.installed,
      5: InstallStatusAndroid.failed,
      6: InstallStatusAndroid.canceled,
      11: InstallStatusAndroid.downloaded,
    };

    playCoreValues.forEach((value, expected) {
      test('maps $value to $expected', () {
        expect(InstallStatusAndroid.fromPlayCoreValue(value), expected);
      });
    });

    test('covers every enum value', () {
      expect(
        playCoreValues.values.toSet(),
        InstallStatusAndroid.values.toSet(),
      );
    });

    test('maps unrecognized values to unknown', () {
      for (final value in [-1, 7, 8, 10, 12, 99]) {
        expect(
          InstallStatusAndroid.fromPlayCoreValue(value),
          InstallStatusAndroid.unknown,
        );
      }
    });
  });

  group('InstallStateAndroid.fromMap', () {
    test('decodes a failed state', () {
      final state = InstallStateAndroid.fromMap({
        'status': 5,
        'bytesDownloaded': 100,
        'totalBytesToDownload': 200,
      });

      expect(state.status, InstallStatusAndroid.failed);
      expect(state.bytesDownloaded, 100);
      expect(state.totalBytesToDownload, 200);
    });

    test('decodes a canceled state', () {
      final state = InstallStateAndroid.fromMap({
        'status': 6,
        'bytesDownloaded': 0,
        'totalBytesToDownload': 0,
      });

      expect(state.status, InstallStatusAndroid.canceled);
    });
  });

  group('AppUpdateInfoAndroid.fromMap', () {
    test('decodes installStatus', () {
      final info = AppUpdateInfoAndroid.fromMap({
        'updateAvailability': 3,
        'availableVersionCode': 42,
        'updatePriority': 0,
        'clientVersionStalenessDays': null,
        'isImmediateUpdateAllowed': true,
        'isFlexibleUpdateAllowed': true,
        'installStatus': 3,
      });

      expect(info.installStatus, InstallStatusAndroid.installing);
    });
  });
}
