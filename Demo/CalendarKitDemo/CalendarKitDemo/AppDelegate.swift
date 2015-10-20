import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    return window
    }()


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    window?.rootViewController = UITableViewController()
    window?.makeKeyAndVisible()


    return true
  }

}

