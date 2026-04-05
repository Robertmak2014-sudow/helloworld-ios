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
    private let textView: UILabel = {
        let label = UILabel()
        label.text = "Текущий статус: Неизвестно"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.numberOfLines = 0
        return label
    }()
    
    private let mainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Обновить статус", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let leftButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Левая кнопка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Правая кнопка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем все элементы на экран
        view.addSubview(textView)
        view.addSubview(mainButton)
        
        let buttonsStack = UIStackView(arrangedSubviews: [leftButton, rightButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 20
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsStack)
        
        // Настройка действий кнопок
        mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        
        // Расстановка ограничений (constraints)
        NSLayoutConstraint.activate([
            // Текстовое поле — сверху по центру
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 50),

            // Кнопка под текстовым полем
            mainButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            mainButton.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            mainButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            mainButton.heightAnchor.constraint(equalToConstant: 50),

            // Блок с двумя кнопками — по центру экрана
            buttonsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            buttonsStack.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func performGETRequest(from urlString: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Ошибка запроса: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }
            
            completion(responseString)
        }
        task.resume()
    }
    
    @objc private func mainButtonTapped() {
        performGETRequest(from: "https://jetong.ru/rele/api.php") { response in
            if let response = response {
                self.textView.text = "Текущий статус: " + response
            } else {
                self.textView.text = "Не удалось получить ответ"
            }
        }



    }

    @objc private func leftButtonTapped() {
        print("Левая кнопка нажата")
    }

    @objc private func rightButtonTapped() {
        print("Правая кнопка нажата")
    }
}
