import UIKit
import CalendarKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = UIColor.white
    window?.makeKeyAndVisible()

    let dayViewController = getDayViewController(.standard)
    //    let dayViewController = getDayViewController(.notification)
    //    let dayViewController = getDayViewController(.customView)

    let navigationController = UINavigationController(rootViewController: dayViewController)
    window?.rootViewController = navigationController

    return true
  }

  func getDayViewController(_ example: Example) -> UIViewController {

    switch example {
    case .standard:
      return ExampleController()
    case .notification:
      return ExampleNotificationController()
    case .customView:
      let customViewController = ExampleCustomTimeLineController()
      // Here we are using a regular UIView but we could set any subclass of UIView
      customViewController.customTimelineView = UIView()
      return customViewController
    }
  }
}

enum Example {
  case standard
  case notification
  case customView
}
