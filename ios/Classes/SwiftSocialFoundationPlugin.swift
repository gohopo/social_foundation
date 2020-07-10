import Flutter
import UIKit

public class SwiftSocialFoundationPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "social_foundation", binaryMessenger: registrar.messenger())
    let instance = SwiftSocialFoundationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

  }
}
