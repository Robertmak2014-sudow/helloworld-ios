import UIKit

// Основной класс приложения
class AppDelegate: UIResponder, UIApplicationDelegate, UITextFieldDelegate {
    var window: UIWindow?
    
    private var messagesLabel = UILabel()
    private var messageTextField = UITextField()
    private var scrollView = UIScrollView()
    private var refreshTimer: Timer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = ViewController()
        rootViewController.delegate = self
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        return true
    }
}

// Контроллер экрана
class ViewController: UIViewController {
    weak var delegate: AppDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startAutoRefresh()
        loadMessages()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Scroll View для сообщений
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Label для отображения сообщений
        messagesLabel.numberOfLines = 0
        messagesLabel.textAlignment = .left
        messagesLabel.font = UIFont.systemFont(ofSize: 16)
        messagesLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(messagesLabel)

        // Поле ввода сообщения
        messageTextField.borderStyle = .roundedRect
        messageTextField.placeholder = "Введите сообщение..."
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.delegate = self  // Устанавливаем делегата
        view.addSubview(messageTextField)

        // Кнопка отправки
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Отправить", for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        view.addSubview(sendButton)

        // Настройка Auto Layout
        NSLayoutConstraint.activate([
            // ScrollView: верхняя часть экрана (70 % высоты)
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -8),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),

            // Messages Label внутри ScrollView
            messagesLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            messagesLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
            messagesLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
            messagesLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            messagesLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -16),

            // TextField внизу экрана: уменьшенные размеры
            messageTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            messageTextField.heightAnchor.constraint(equalToConstant: 44),
            messageTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),  // 70 % ширины экрана

            // Кнопка справа от TextField
            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 80),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // Делегат UITextField: обработка нажатия Enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true  // Скрываем клавиатуру после отправки
    }

    @objc private func sendMessage() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        let urlString = "https://jetong.ru/messenger/send.php?text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { _, _, error in
            DispatchQueue.main.async {
                if error == nil {
                    self.messageTextField.text = ""
            self.loadMessages()
        }
    }.resume()
    }

    private func loadMessages() {
        let url = URL(string: "https://jetong.ru/messenger/receive.php")!
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data, let string = String(data: data, encoding: .utf8) {
                    let messages = string.components(separatedBy: "\n").filter { !$0.isEmpty }
            let formattedMessages = messages.map { "• \($0)" }.joined(separator: "\n")
            self.messagesLabel.text = formattedMessages
            // Прокрутка вниз к последнему сообщению
            let bottomOffset = CGPoint(x: 0, y: max(self.messagesLabel.frame.size.height - self.scrollView.frame.size.height, 0))
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }.resume()
    }

    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.loadMessages()
        }
    }
}

// Точка входа приложения
@main
struct AppEntryPoint {
    static func main() {
        UIApplication.shared.delegate = AppDelegate()
        _ = UIApplicationMain(
            CommandLine.argc,
            CommandLine.unsafeArgv,
            nil,
            NSStringFromClass(AppDelegate.self)
        )
    }
}
