import UIKit
import Flutter
import StoreKit

public class InAppUpdateFlutterPlugin: NSObject, FlutterPlugin, SKStoreProductViewControllerDelegate {
  var flutterResult: FlutterResult?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "in_app_update_flutter", binaryMessenger: registrar.messenger())
    let instance = InAppUpdateFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Resolves the view controller to present from at call time. Capturing the
  /// root view controller at registration is unreliable: on app launch the
  /// window/rootViewController may not be set yet (especially with scene-based
  /// lifecycles), leaving it nil for the lifetime of the plugin.
  private func topViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }

    var top = keyWindow?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "checkForUpdateIos" {
      checkForUpdate(result: result)
    } else if call.method == "showStoreUpdateIos",
       let args = call.arguments as? [String: Any],
       let appStoreId = args["appStoreId"] as? String {
      flutterResult = result
      showStoreProductView(appStoreId: appStoreId)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  /// Looks the app up on the App Store by bundle identifier and compares the
  /// store version with the installed one. `result` is captured per call rather
  /// than stored in `flutterResult`, so concurrent checks don't overwrite each
  /// other.
  private func checkForUpdate(result: @escaping FlutterResult) {
    guard let bundleId = Bundle.main.bundleIdentifier else {
      result(FlutterError(code: "NO_BUNDLE_ID", message: "The app has no bundle identifier", details: nil))
      return
    }

    guard let installedVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
      result(FlutterError(code: "NO_INSTALLED_VERSION", message: "The app has no CFBundleShortVersionString", details: nil))
      return
    }

    var components = URLComponents(string: "https://itunes.apple.com/lookup")!
    components.queryItems = [URLQueryItem(name: "bundleId", value: bundleId)]
    if let country = lookupCountryCode() {
      components.queryItems?.append(URLQueryItem(name: "country", value: country))
    }

    var request = URLRequest(url: components.url!)
    request.cachePolicy = .reloadIgnoringLocalCacheData

    URLSession.shared.dataTask(with: request) { data, response, error in
      let outcome = Self.checkUpdateOutcome(
        data: data,
        response: response,
        error: error,
        installedVersion: installedVersion
      )
      DispatchQueue.main.async {
        result(outcome)
      }
    }.resume()
  }

  /// The country for the lookup: the user's App Store storefront, then the
  /// device region, then nil (the lookup's default store).
  private func lookupCountryCode() -> String? {
    if let storefront = SKPaymentQueue.default().storefront?.countryCode,
       let alpha2 = AppStoreVersion.alpha2CountryCode(fromAlpha3: storefront) {
      return alpha2.lowercased()
    }
    return Locale.current.regionCode?.lowercased()
  }

  /// Turns the lookup response into either the result map or a FlutterError.
  private static func checkUpdateOutcome(
    data: Data?,
    response: URLResponse?,
    error: Error?,
    installedVersion: String
  ) -> Any {
    if let error = error {
      return FlutterError(code: "CHECK_UPDATE_FAILED", message: "Failed to check for updates", details: error.localizedDescription)
    }

    if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
      return FlutterError(code: "CHECK_UPDATE_FAILED", message: "Failed to check for updates", details: "HTTP \(httpResponse.statusCode)")
    }

    guard let data = data,
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let results = json["results"] as? [[String: Any]] else {
      return FlutterError(code: "CHECK_UPDATE_FAILED", message: "Failed to check for updates", details: "Invalid lookup response")
    }

    guard let storeVersion = results.first?["version"] as? String else {
      return FlutterError(code: "APP_NOT_FOUND", message: "The app was not found on the App Store", details: nil)
    }

    guard let isUpdateAvailable = AppStoreVersion.isNewer(storeVersion: storeVersion, than: installedVersion) else {
      return FlutterError(
        code: "VERSION_PARSE_FAILED",
        message: "Versions must be period-separated integers",
        details: "store: \(storeVersion), installed: \(installedVersion)"
      )
    }

    return [
      "isUpdateAvailable": isUpdateAvailable,
      "storeVersion": storeVersion,
      "installedVersion": installedVersion,
    ]
  }

  private func showStoreProductView(appStoreId: String) {
    // StoreKit requires the iTunes item identifier as an NSNumber. Passing a
    // String causes loadProduct(withParameters:) to silently fail (loaded == false,
    // error == nil), which surfaces as STORE_NOT_LOADED.
    guard let appStoreIdNumber = Int(appStoreId) else {
      flutterResult?(FlutterError(code: "INVALID_APP_STORE_ID", message: "appStoreId must be a numeric value", details: appStoreId))
      return
    }

    let productViewController = SKStoreProductViewController()
    productViewController.delegate = self

    let parameters = [SKStoreProductParameterITunesItemIdentifier : NSNumber(value: appStoreIdNumber)]

    productViewController.loadProduct(withParameters: parameters) { loaded, error in
      if let error = error {
        self.flutterResult?(FlutterError(code: "STORE_ERROR", message: "Failed to load product", details: error.localizedDescription))
        return
      }

      guard loaded else {
        self.flutterResult?(FlutterError(code: "STORE_NOT_LOADED", message: "Could not load product", details: nil))
        return
      }

      guard let vc = self.topViewController() else {
        self.flutterResult?(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No view controller available to present the App Store overlay", details: nil))
        return
      }

      vc.present(productViewController, animated: true) {
        self.flutterResult?(nil)
      }
    }
  }

  public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }
}
