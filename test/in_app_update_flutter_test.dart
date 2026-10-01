import 'package:in_app_update_flutter/in_app_update_flutter.dart';
import 'package:in_app_update_flutter/src/method_channel/in_app_update_flutter_method_channel.dart';
import 'package:in_app_update_flutter/src/platform_interface/in_app_update_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// A valid mock that extends [InAppUpdateFlutterPlatform], giving it
/// the correct token so it can be set as the platform instance.
class _MockPlatform extends InAppUpdateFlutterPlatform {
  String? lastAppStoreId;

  @override
  Future<void> showUpdateForIos({required String appStoreId}) async {
    lastAppStoreId = appStoreId;
  }

  @override
  // ignore: deprecated_member_use_from_same_package
  Future<void> showUpdate({required String appStoreId}) async {
    lastAppStoreId = appStoreId;
  }

  String? lastRegion;

  @override
  Future<AppUpdateInfoIos> checkUpdateIos({String? region}) async {
    lastRegion = region;
    return const AppUpdateInfoIos(
      storeVersion: '2.0.0',
      installedVersion: '1.0.0',
      updateAvailable: true,
      bundleId: 'com.example.app',
    );
  }

  @override
  Future<AppUpdateInfoAndroid> checkUpdateAndroid() async {
    return const AppUpdateInfoAndroid(
      updateAvailability: UpdateAvailabilityAndroid.updateAvailable,
      availableVersionCode: 42,
      updatePriority: 3,
      clientVersionStalenessDays: 7,
      isImmediateUpdateAllowed: true,
      isFlexibleUpdateAllowed: true,
      installStatus: InstallStatusAndroid.unknown,
    );
  }

  @override
  Future<UpdateResultAndroid> startImmediateUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) async {
    return UpdateResultAndroid.success;
  }

  @override
  Future<UpdateResultAndroid> startFlexibleUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) async {
    return UpdateResultAndroid.success;
  }

  @override
  Future<void> completeUpdateAndroid() async {}

  @override
  Stream<InstallStateAndroid> get installStateStreamAndroid =>
      const Stream.empty();
}

/// Minimal subclass that does NOT override the abstract methods,
/// so calls fall through to the base-class throw.
class _UnimplementedPlatform extends InAppUpdateFlutterPlatform {}

void main() {
  group('InAppUpdateFlutterPlatform', () {
    tearDown(() {
      // Restore default instance after each test.
      InAppUpdateFlutterPlatform.instance = MethodChannelInAppUpdateFlutter();
    });

    test('default instance is MethodChannelInAppUpdateFlutter', () {
      expect(
        InAppUpdateFlutterPlatform.instance,
        isA<MethodChannelInAppUpdateFlutter>(),
      );
    });

    test('instance can be replaced with a valid mock', () {
      final mock = _MockPlatform();
      InAppUpdateFlutterPlatform.instance = mock;
      expect(InAppUpdateFlutterPlatform.instance, same(mock));
    });

    test('setting instance back to MethodChannel works', () {
      InAppUpdateFlutterPlatform.instance = _MockPlatform();
      InAppUpdateFlutterPlatform.instance = MethodChannelInAppUpdateFlutter();
      expect(
        InAppUpdateFlutterPlatform.instance,
        isA<MethodChannelInAppUpdateFlutter>(),
      );
    });

    group('base class throws UnimplementedError', () {
      late _UnimplementedPlatform platform;

      setUp(() {
        platform = _UnimplementedPlatform();
      });

      test('showUpdate throws UnimplementedError', () {
        expect(
          // ignore: deprecated_member_use_from_same_package
          () => platform.showUpdate(appStoreId: '123'),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('showUpdateForIos throws UnimplementedError', () {
        expect(
          () => platform.showUpdateForIos(appStoreId: '123'),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('checkUpdateIos throws UnimplementedError', () {
        expect(
          () => platform.checkUpdateIos(),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('checkUpdateAndroid throws UnimplementedError', () {
        expect(
          () => platform.checkUpdateAndroid(),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('startImmediateUpdateAndroid throws UnimplementedError', () {
        expect(
          () => platform.startImmediateUpdateAndroid(),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('startFlexibleUpdateAndroid throws UnimplementedError', () {
        expect(
          () => platform.startFlexibleUpdateAndroid(),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('completeUpdateAndroid throws UnimplementedError', () {
        expect(
          () => platform.completeUpdateAndroid(),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('installStateStreamAndroid throws UnimplementedError', () {
        expect(
          () => platform.installStateStreamAndroid,
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('mock platform delegates', () {
      test('showUpdateForIos passes appStoreId to mock', () async {
        final mock = _MockPlatform();
        InAppUpdateFlutterPlatform.instance = mock;

        await InAppUpdateFlutterPlatform.instance
            .showUpdateForIos(appStoreId: '544007664');
        expect(mock.lastAppStoreId, '544007664');
      });

      test('checkUpdateIos returns expected info', () async {
        final mock = _MockPlatform();
        InAppUpdateFlutterPlatform.instance = mock;

        final info = await InAppUpdateFlutterPlatform.instance.checkUpdateIos();
        expect(info.storeVersion, '2.0.0');
        expect(info.installedVersion, '1.0.0');
        expect(info.updateAvailable, isTrue);
        expect(info.bundleId, 'com.example.app');
      });

      test('checkUpdateIos forwards the region override', () async {
        final mock = _MockPlatform();
        InAppUpdateFlutterPlatform.instance = mock;

        await InAppUpdateFlutterPlatform.instance.checkUpdateIos(region: 'gb');
        expect(mock.lastRegion, 'gb');
      });

      test('checkUpdateAndroid returns expected info', () async {
        final mock = _MockPlatform();
        InAppUpdateFlutterPlatform.instance = mock;

        final info =
            await InAppUpdateFlutterPlatform.instance.checkUpdateAndroid();
        expect(
          info.updateAvailability,
          UpdateAvailabilityAndroid.updateAvailable,
        );
        expect(info.availableVersionCode, 42);
        expect(info.updatePriority, 3);
      });

      test('startImmediateUpdateAndroid returns success', () async {
        final mock = _MockPlatform();
        InAppUpdateFlutterPlatform.instance = mock;

        final result = await InAppUpdateFlutterPlatform.instance
            .startImmediateUpdateAndroid();
        expect(result, UpdateResultAndroid.success);
      });

      test('startFlexibleUpdateAndroid returns success', () async {
        final mock = _MockPlatform();
        InAppUpdateFlutterPlatform.instance = mock;

        final result = await InAppUpdateFlutterPlatform.instance
            .startFlexibleUpdateAndroid();
        expect(result, UpdateResultAndroid.success);
      });
    });
  });
}
