import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ExposureManager.shared.initialize()

        if Configuration.hasSeenOnboarding() {
            ExposureManager.shared.start()
        }

        // Setting ourself as delegate to display the notification also when app in foreground.
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        ExposureManager.shared.sync()
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // This is called when app was in background and user tapped notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse, withCompletionHandler
        completionHandler: @escaping () -> Void) {

        return completionHandler()
    }

    // This is called when app was in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent
        notification: UNNotification, withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {

        return completionHandler(.alert)
    }

}
