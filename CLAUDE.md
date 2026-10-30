# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

Standard federated-style layering inside a single package:

1. `lib/in_app_update_flutter.dart` — public `InAppUpdateFlutter` facade; re-exports `lib/src/models/models.dart`. Platform guards live here (e.g. `checkUpdateIos` throws `UnsupportedError` off iOS).
2. `lib/src/platform_interface/` — `InAppUpdateFlutterPlatform` (`plugin_platform_interface` token pattern); every method throws `UnimplementedError` by default. Tests swap `instance` with a mock.
3. `lib/src/method_channel/` — `MethodChannelInAppUpdateFlutter`: MethodChannel `in_app_update_flutter` + EventChannel `in_app_update_flutter/installStateAndroid`. Note native method names differ from Dart names (`showStoreUpdateIos`, `checkForUpdateIos`, `checkForUpdateAndroid`, `startImmediateUpdateAndroid`, `startFlexibleUpdateAndroid`, `completeUpdateAndroid`).
4. `lib/src/models/` — one file per type; each parses a map/int from native (`fromMap` / `fromValue`). Integer enums must match native constants exactly (e.g. `InstallStatusAndroid` uses Play Core `InstallStatus` values; `UpdateResultAndroid` uses 0/1/2 mapped from activity result codes in Kotlin `onActivityResult`).
5. Native:
   - `android/src/main/kotlin/.../InAppUpdateFlutterPlugin.kt` — single class implementing `FlutterPlugin`, `ActivityAware`, `MethodCallHandler`, `EventChannel.StreamHandler`, `ActivityResultListener`. Start-update calls store a single `pendingResult` (hence `ALREADY_RUNNING`) completed later in `onActivityResult`; it must also be failed if the Play flow never starts. The internal constructor takes an `(Activity) -> AppUpdateManager` factory so tests inject a mock manager.
   - `ios/in_app_update_flutter/Sources/in_app_update_flutter/` — Swift plugin plus `CountryCodes.swift` (StoreKit storefronts are alpha-3, iTunes Lookup needs alpha-2). Layout supports both CocoaPods (`ios/in_app_update_flutter.podspec`) and SwiftPM (`Package.swift`).

When changing the API, keep all layers in sync: facade → platform interface → method channel → models → Kotlin/Swift → Dart tests (`test/`) → Kotlin tests. Error codes are part of the public contract and are documented in README's "Error Handling" tables; add/update them there.

## Git workflow

- **Before committing,** create a branch for the work. Don't commit straight to `production`.
- **Branch name:** `<type>/<short-kebab-title>`, where `<type>` is the Conventional Commits type for the change:
  - bug fix → `fix/<short-kebab-title>`
  - new feature → `feat/<short-kebab-title>`
  - other work uses the closest type: `chore`, `refactor`, `perf`, `docs`, `test`, `ci`. An enhancement that changes behavior is `feat`; a cleanup with no behavior change is `refactor` or `chore`.
- **Commit message:** Conventional Commits message, e.g. `fix(auth): handle expired session token`.
- **Releases:** version bumps happen on a dedicated release branch. Feature and fix branches must not change the `version:` in `pubspec.yaml` (or its entry in `example/pubspec.lock`), and must not edit `CHANGELOG.md` or `README.md`.