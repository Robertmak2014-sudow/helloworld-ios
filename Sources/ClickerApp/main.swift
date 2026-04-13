import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

class ViewController: UIViewController {
    private let countLabel: UILabel = {
        let label = UILabel()
        label.text = "Счётчик: 0"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let clickButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("КЛИК!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сброс", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 12
        return button
    }()

    private var clickCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем элементы на экран
        view.addSubview(countLabel)
        view.addSubview(clickButton)
        view.addSubview(resetButton)
        
        // Настройка действий кнопок
        clickButton.addTarget(self, action: #selector(clickButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        // Расстановка ограничений (constraints)
        NSLayoutConstraint.activate([
            // Счётчик — сверху по центру
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            
            // Кнопка клика — по центру ниже счётчика
            clickButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clickButton.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 40),
            clickButton.widthAnchor.constraint(equalToConstant: 160),
            clickButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Кнопка сброса — по центру внизу
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.topAnchor.constraint(equalTo: clickButton.bottomAnchor, constant: 20),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            resetButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func clickButtonTapped() {
        clickCount += 1
        countLabel.text = "Счётчик: \(clickCount)"
        // Лёгкая вибрация при клике (опционально)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    @objc private func resetButtonTapped() {
        clickCount = 0
        countLabel.text = "Счётчик: 0"
    }
}
