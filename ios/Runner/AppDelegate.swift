import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 배너 광고는 별도 네이티브 팩토리가 필요하지 않음
    
    // Firebase AppDelegate Proxy가 비활성화되어 있으므로 수동으로 설정
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      
      // iOS 알림 카테고리 등록
      let keywordCategory = UNNotificationCategory(
        identifier: "KEYWORD_NOTIFICATION",
        actions: [],
        intentIdentifiers: [],
        options: .customDismissAction
      )
      
      UNUserNotificationCenter.current().setNotificationCategories([keywordCategory])
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
