import UIKit
import CalendarKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = UIColor.white
    window?.makeKeyAndVisible()

    let dayViewController = ExampleController()
    let navigationController = UINavigationController(rootViewController: dayViewController)
    window?.rootViewController = navigationController

    return true
  }
}
