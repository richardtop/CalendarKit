import UIKit
import CalendarKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    return window
    }()


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {


    let vc = DayViewController()
    vc.view.backgroundColor = UIColor.redColor()

    window?.rootViewController = vc
    vc.view.layoutSubviews()
    window?.makeKeyAndVisible()


    return true
  }

}

