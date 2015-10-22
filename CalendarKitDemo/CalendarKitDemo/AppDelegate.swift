import UIKit
import CalendarKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.backgroundColor = UIColor.whiteColor()
    window?.makeKeyAndVisible()

    let dayViewController = DayViewController()
    let navigationController = UINavigationController(rootViewController: dayViewController)
    window?.rootViewController = navigationController

    return true
  }
}

