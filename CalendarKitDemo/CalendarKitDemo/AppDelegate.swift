import UIKit
import CalendarKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.backgroundColor = UIColor.whiteColor()
    window?.makeKeyAndVisible()

    let vc = DayViewController()
    let navigationController = UINavigationController(rootViewController: vc)
    window?.rootViewController = navigationController

    return true
  }
}

