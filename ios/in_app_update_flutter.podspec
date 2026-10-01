#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint in_app_update_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'in_app_update_flutter'
  s.version          = '3.0.1'
  s.summary          = 'In-app updates for iOS (StoreKit) and Android (Play Core).'
  s.description      = <<-DESC
A Flutter plugin to prompt users for in-app updates using StoreKit on iOS and the Play Core API on Android, supporting both immediate and flexible update flows.
                       DESC
  s.homepage         = 'https://github.com/buildwithpulkit/in_app_update_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Pulkit Agarwal' => 'support@pulkitagarwal.me' }
  s.source           = { :path => '.' }
  s.source_files = 'in_app_update_flutter/Sources/in_app_update_flutter/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {'in_app_update_flutter_privacy' => ['in_app_update_flutter/Sources/in_app_update_flutter/PrivacyInfo.xcprivacy']}
end
