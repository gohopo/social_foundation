import Flutter
import UIKit
import LeanCloud

public class SwiftSocialFoundationPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "social_foundation", binaryMessenger: registrar.messenger())
    let instance = SwiftSocialFoundationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as! [String: Any]
    if call.method == "initialize" {
      LCApplication.logLevel = .all
      do{
        try LCApplication.default.set(
          id: arguments["appId"] as! String,
          key: arguments["appKey"] as! String,
          serverURL: arguments["serverURL"] as! String
        )
        result("")
      }
      catch{
        print(error)
        result( error)
      }
    }
  }
}
