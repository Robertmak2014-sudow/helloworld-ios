import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var clickCount = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        self.window = window

        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .white

        // Создаём метку для отображения счёта
        let countLabel = UILabel()
        countLabel.text = "0"
        countLabel.textColor = .black
        countLabel.textAlignment = .center
        countLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        countLabel.frame = CGRect(x: 0, y: 200, width: 300, height: 60)
        rootViewController.view.addSubview(countLabel)

        // Создаём кнопку клика
        let clickButton = UIButton(type: .system)
        clickButton.setTitle("CLICK ME!", for: .normal)
        clickButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        clickButton.backgroundColor = .systemBlue
        clickButton.layer.cornerRadius = 12
        clickButton.frame = CGRect(x: 100, y: 300, width: 200, height: 60)

        // Обработчик нажатия кнопки
        clickButton.addTarget(self, action: #selector(handleClick), for: .touchUpInside)
        rootViewController.view.addSubview(clickButton)

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        return true
    }

    @objc private func handleClick() {
        clickCount += 1
        if let countLabel = window?.rootViewController?.view.subviews.first(where: { $0 is UILabel }) as? UILabel {
            countLabel.text = "\(clickCount)"
            // Меняем цвет при достижении 10 кликов
            if clickCount >= 10 {
                countLabel.textColor = .green
            }
        }
        // Лёгкая вибрация при клике
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
