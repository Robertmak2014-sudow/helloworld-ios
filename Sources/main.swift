import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        self.window = window

        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .white

        let label = UILabel()
        label.text = "Hello, World!"
        label.textColor = .black
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 200, width: 300, height: 50)
        rootViewController.view.addSubview(label)

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        return true
    }
}
