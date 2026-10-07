import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

void main() {
  group('AppUpdateInfoIos.fromMap', () {
    test('decodes an available update', () {
      final info = AppUpdateInfoIos.fromMap({
        'isUpdateAvailable': true,
        'storeVersion': '2.0.0',
        'installedVersion': '1.9.3',
      });

      expect(info.isUpdateAvailable, true);
      expect(info.storeVersion, '2.0.0');
      expect(info.installedVersion, '1.9.3');
    });

    test('decodes no update', () {
      final info = AppUpdateInfoIos.fromMap({
        'isUpdateAvailable': false,
        'storeVersion': '1.2',
        'installedVersion': '1.2.0',
      });

      expect(info.isUpdateAvailable, false);
    });
  });
}
