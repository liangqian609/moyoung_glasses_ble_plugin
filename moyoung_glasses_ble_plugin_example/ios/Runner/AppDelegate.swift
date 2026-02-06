import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // 注册所有插件（包括第三方插件）
      GeneratedPluginRegistrant.register(with: self)
      
      // 先调用父类方法
      let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
      
      // 手动注册我们的插件（暂时屏蔽，自动注册应该已经足够）
      /*
      if let flutterViewController = window?.rootViewController as? FlutterViewController {
          let registrar = flutterViewController.registrar(forPlugin: "MoyoungGlassesBlePlugin")
          if let registrar = registrar {
              // 使用 Objective-C 运时调用
              if let pluginClass = NSClassFromString("MoyoungGlassesBlePlugin") as? NSObject.Type {
                  let selector = NSSelectorFromString("registerWithRegistrar:")
                  if pluginClass.responds(to: selector) {
                      pluginClass.perform(selector, with: registrar)
                      print("手动注册 MoyoungGlassesBlePlugin 成功")
                  }
              }
          }
      }
      */
      
      return result
  }
}
