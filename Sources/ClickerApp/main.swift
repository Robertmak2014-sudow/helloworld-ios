import UIKit

// Главный класс приложения
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

// Основной экран приложения
class ViewController: UIViewController {
    private var clickCount = 0
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let clickButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Click me!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLabel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем элементы на экран
        view.addSubview(label)
        view.addSubview(clickButton)
        
        // Настраиваем ограничения (Auto Layout)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            clickButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clickButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            clickButton.widthAnchor.constraint(equalToConstant: 150),
            clickButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Назначаем действие для кнопки
        clickButton.addTarget(self, action: #selector(handleClick), for: .touchUpInside)
    }
    
    @objc private func handleClick() {
        clickCount += 1
        updateLabel()
        
        
    }
    
    private func updateLabel() {
        label.text = "Clicks: \(clickCount)"
    }
}

// Точка входа приложения
@UIApplicationMain
class AppDelegateWrapper: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
