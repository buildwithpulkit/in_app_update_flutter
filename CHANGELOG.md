## 3.0.1

- **Fixed Android install statuses being decoded incorrectly.** `InstallStatusAndroid` now uses Play Core's actual `InstallStatus` values. Previously a failed update was reported as `installing`, a canceled one as `installed`, and real `installing`/`installed` states as `unknown`. This affects both `installStateStreamAndroid` events and `AppUpdateInfoAndroid.installStatus`.
- **Fixed `startImmediateUpdateAndroid` and `startFlexibleUpdateAndroid` hanging when Google Play doesn't start the update flow.** They now throw a `PlatformException` with code `UPDATE_NOT_STARTED` when Play declines to start the flow, or `START_UPDATE_FAILED` when launching it throws (the message is in `details`). Previously the future never completed, every later start call failed with `ALREADY_RUNNING`, and a launch exception could crash the app.
- Moved the Android plugin package from `tech.axions.in_app_update_flutter` to `me.pulkitagarwal.in_app_update_flutter`. Flutter's generated plugin registration picks this up automatically; it only affects native Android code or ProGuard/R8 rules that reference `InAppUpdateFlutterPlugin` by its fully qualified name.
- Moved the repository, homepage and issue tracker to github.com/buildwithpulkit/in_app_update_flutter, and updated the author and license holder to Pulkit Agarwal.
- README: added an Error Handling section listing every Android and iOS error code and an `InstallStateAndroid` fields table, fixed the flexible update example (`state.installStatus` → `state.status`), and listed `inAppUpdateFailed` as a possible immediate update result.

## 3.0.0

- **Fixed iOS `showUpdateForIos` always failing with `STORE_NOT_LOADED`.** The App Store ID is now passed to StoreKit as an `NSNumber` (as required by `SKStoreProductParameterITunesItemIdentifier`) instead of a `String`, so the App Store overlay loads correctly.
- Fixed the App Store overlay failing to present because the view controller was captured (and often `nil`) at plugin registration. It is now resolved at call time via the active window scene.
- Added distinct error codes for clearer diagnostics: `INVALID_APP_STORE_ID` (non-numeric ID) and `NO_VIEW_CONTROLLER` (nothing available to present from), separate from `STORE_NOT_LOADED`.
- **BREAKING:** Raised the minimum supported iOS version from 12.0 to 13.0.

## 2.0.3

- Fixed README screenshots not rendering on pub.dev by using absolute GitHub raw URLs

## 2.0.2

- Added `homepage` and `issue_tracker` fields to pubspec.yaml for pub.dev sidebar links
- Updated pub.dev topics for better discoverability.
- Updated screenshots for Android immediate and flexible update flow

## 2.0.1

- Added pub.dev screenshots for iOS, Android immediate, and Android flexible update flows
- Updated package description to reflect both iOS (StoreKit) and Android (Play Core) support
- Updated repository URL and author to Axions

## 2.0.0

- Added Android in-app updates support via Google Play's In-App Updates API
- Added `checkUpdateAndroid()` to retrieve update availability and metadata
- Added `startImmediateUpdateAndroid()` for full-screen, blocking update flow
- Added `startFlexibleUpdateAndroid()` for background download update flow
- Added `completeUpdateAndroid()` to apply a downloaded flexible update
- Added `installStateStreamAndroid` stream for monitoring flexible update download progress
- Added `AppUpdateInfoAndroid`, `InstallStateAndroid`, `InstallStatusAndroid`, `UpdateAvailabilityAndroid`, and `UpdateResultAndroid` models
- Renamed `showUpdate()` to `showUpdateForIos()` (old method is deprecated)
- Updated Android toolchain to latest stable versions

## 1.0.4

- Added Swift Package Manager (SPM) support for iOS while maintaining CocoaPods backward compatibility
- Restructured iOS plugin sources into SPM-compatible directory layout
- Updated podspec metadata (version, summary, description, homepage, author)
- Enabled PrivacyInfo.xcprivacy resource bundle
- Fixed iOS unit tests to match actual plugin API
- Shortened package description to meet pub.dev requirements

## 1.0.3

- Restructured plugin with federated architecture pattern

## 1.0.2

- Updated README and package metadata

## 1.0.1

- Minor documentation fixes

## 1.0.0

- Initial release: iOS in-app update support via SKStoreProductViewController (StoreKit)
