import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update_flutter/in_app_update_flutter.dart';
import 'package:in_app_update_flutter/src/method_channel/in_app_update_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('in_app_update_flutter');

  late MethodChannelInAppUpdateFlutter plugin;

  setUp(() {
    plugin = MethodChannelInAppUpdateFlutter();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  group('MethodChannelInAppUpdateFlutter', () {
    group('showUpdateForIos', () {
      test('calls showStoreUpdateIos method on the channel', () async {
        String? invokedMethod;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              invokedMethod = call.method;
              return null;
            });

        await plugin.showUpdateForIos(appStoreId: '544007664');
        expect(invokedMethod, 'showStoreUpdateIos');
      });

      test('passes appStoreId argument to the channel', () async {
        Map<dynamic, dynamic>? invokedArgs;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              invokedArgs = call.arguments as Map<dynamic, dynamic>;
              return null;
            });

        await plugin.showUpdateForIos(appStoreId: '544007664');
        expect(invokedArgs, {'appStoreId': '544007664'});
      });

      test('propagates platform errors', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              throw PlatformException(
                code: 'STORE_ERROR',
                message: 'Failed to load product',
              );
            });

        expect(
          () => plugin.showUpdateForIos(appStoreId: '544007664'),
          throwsA(isA<PlatformException>()),
        );
      });
    });

    group('checkUpdateIos', () {
      test('calls checkForUpdateIos and deserializes response', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              expect(call.method, 'checkForUpdateIos');
              expect(call.arguments, isNull);
              return {
                'updateAvailability': 'updateIncompatible',
                'installedVersion': '2.1',
                'storeVersion': '2.2.0',
                'appStoreId': '544007664',
                'storeUrl': 'https://apps.apple.com/in/app/id544007664?uo=4',
                'country': 'in',
                'minimumOsVersion': '17.0',
              };
            });

        final info = await plugin.checkUpdateIos();
        expect(
          info.updateAvailability,
          UpdateAvailabilityIos.updateIncompatible,
        );
        expect(info.installedVersion, '2.1');
        expect(info.storeVersion, '2.2.0');
        expect(info.appStoreId, '544007664');
        expect(info.storeUrl, 'https://apps.apple.com/in/app/id544007664?uo=4');
        expect(info.country, 'in');
        expect(info.minimumOsVersion, '17.0');
      });

      test('handles null minimumOsVersion', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              return {
                'updateAvailability': 'updateNotAvailable',
                'installedVersion': '2.2.0',
                'storeVersion': '2.2.0',
                'appStoreId': '544007664',
                'storeUrl': 'https://apps.apple.com/in/app/id544007664',
                'country': 'in',
                'minimumOsVersion': null,
              };
            });

        final info = await plugin.checkUpdateIos();
        expect(
          info.updateAvailability,
          UpdateAvailabilityIos.updateNotAvailable,
        );
        expect(info.minimumOsVersion, isNull);
      });

      for (final code in [
        'MISSING_BUNDLE_ID',
        'STOREFRONT_UNAVAILABLE',
        'NETWORK_ERROR',
        'HTTP_ERROR',
        'INVALID_RESPONSE',
        'APP_NOT_FOUND',
        'INVALID_VERSION',
      ]) {
        test('propagates $code', () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(methodChannel, (call) async {
                throw PlatformException(code: code);
              });

          expect(
            () => plugin.checkUpdateIos(),
            throwsA(
              isA<PlatformException>().having((e) => e.code, 'code', code),
            ),
          );
        });
      }
    });

    group('checkUpdateAndroid', () {
      test('calls checkForUpdateAndroid and deserializes response', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              expect(call.method, 'checkForUpdateAndroid');
              return {
                'updateAvailability': 2,
                'availableVersionCode': 42,
                'updatePriority': 3,
                'clientVersionStalenessDays': 7,
                'isImmediateUpdateAllowed': true,
                'isFlexibleUpdateAllowed': true,
                'installStatus': 0,
              };
            });

        final info = await plugin.checkUpdateAndroid();
        expect(
          info.updateAvailability,
          UpdateAvailabilityAndroid.updateAvailable,
        );
        expect(info.availableVersionCode, 42);
        expect(info.updatePriority, 3);
        expect(info.clientVersionStalenessDays, 7);
        expect(info.isImmediateUpdateAllowed, true);
        expect(info.isFlexibleUpdateAllowed, true);
        expect(info.installStatus, InstallStatusAndroid.unknown);
      });

      test('handles null optional fields', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              return {
                'updateAvailability': 1,
                'availableVersionCode': null,
                'updatePriority': 0,
                'clientVersionStalenessDays': null,
                'isImmediateUpdateAllowed': false,
                'isFlexibleUpdateAllowed': false,
                'installStatus': 0,
              };
            });

        final info = await plugin.checkUpdateAndroid();
        expect(
          info.updateAvailability,
          UpdateAvailabilityAndroid.updateNotAvailable,
        );
        expect(info.availableVersionCode, isNull);
        expect(info.clientVersionStalenessDays, isNull);
      });

      test('propagates platform errors', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              throw PlatformException(
                code: 'CHECK_UPDATE_FAILED',
                message: 'Failed to check for updates',
              );
            });

        expect(
          () => plugin.checkUpdateAndroid(),
          throwsA(isA<PlatformException>()),
        );
      });
    });

    group('startImmediateUpdateAndroid', () {
      test('calls startImmediateUpdateAndroid with default args', () async {
        Map<dynamic, dynamic>? invokedArgs;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              expect(call.method, 'startImmediateUpdateAndroid');
              invokedArgs = call.arguments as Map<dynamic, dynamic>;
              return 0;
            });

        final result = await plugin.startImmediateUpdateAndroid();
        expect(result, UpdateResultAndroid.success);
        expect(invokedArgs?['allowAssetPackDeletion'], false);
      });

      test('passes allowAssetPackDeletion argument', () async {
        Map<dynamic, dynamic>? invokedArgs;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              invokedArgs = call.arguments as Map<dynamic, dynamic>;
              return 0;
            });

        await plugin.startImmediateUpdateAndroid(allowAssetPackDeletion: true);
        expect(invokedArgs?['allowAssetPackDeletion'], true);
      });

      test('returns userCanceled when result is 1', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              return 1;
            });

        final result = await plugin.startImmediateUpdateAndroid();
        expect(result, UpdateResultAndroid.userCanceled);
      });

      test('returns inAppUpdateFailed when result is 2', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              return 2;
            });

        final result = await plugin.startImmediateUpdateAndroid();
        expect(result, UpdateResultAndroid.inAppUpdateFailed);
      });
    });

    group('startFlexibleUpdateAndroid', () {
      test('calls startFlexibleUpdateAndroid and returns success', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              expect(call.method, 'startFlexibleUpdateAndroid');
              return 0;
            });

        final result = await plugin.startFlexibleUpdateAndroid();
        expect(result, UpdateResultAndroid.success);
      });
    });

    group('completeUpdateAndroid', () {
      test('calls completeUpdateAndroid on the channel', () async {
        String? invokedMethod;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(methodChannel, (call) async {
              invokedMethod = call.method;
              return null;
            });

        await plugin.completeUpdateAndroid();
        expect(invokedMethod, 'completeUpdateAndroid');
      });
    });
  });
}
