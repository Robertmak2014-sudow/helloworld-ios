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

class ViewController: UIViewController, UITextFieldDelegate {

    private var messagesLabel: UILabel!
    private var messageTextField: UITextField!
    private var scrollView: UIScrollView!
    private var refreshTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startAutoRefresh()
        loadMessages()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // ScrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // MessagesLabel
        messagesLabel = UILabel()
        messagesLabel.numberOfLines = 0
        messagesLabel.textAlignment = .left
        messagesLabel.font = UIFont.systemFont(ofSize: 16)
        messagesLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(messagesLabel)

        // TextField
        messageTextField = UITextField()
        messageTextField.borderStyle = .roundedRect
        messageTextField.placeholder = "Введите сообщение..."
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.delegate = self
        view.addSubview(messageTextField)

        // Кнопка отправки
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Отправить", for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        view.addSubview(sendButton)

        // Auto Layout
        NSLayoutConstraint.activate([
            // ScrollView: 70 % высоты экрана
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -8),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),

            // MessagesLabel внутри ScrollView
            messagesLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            messagesLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
            messagesLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
            messagesLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            messagesLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -16),

            // TextField внизу экрана
            messageTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            messageTextField.heightAnchor.constraint(equalToConstant: 44),
            messageTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),

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
        return true // Скрываем клавиатуру после отправки
    }

    @objc private func sendMessage() {
        guard let text = messageTextField.text, !text.isEmpty else { return }

        guard var urlComponents = URLComponents(string: "https://jetong.ru/messenger/send.php") else { return }
        urlComponents.queryItems = [URLQueryItem(name: "text", value: text)]

        guard let url = urlComponents.url else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] _, _, error in
            DispatchQueue.main.async {
                if error == nil {
                    self?.messageTextField.text = ""
            self?.loadMessages()
        }
    }
        task.resume()
    }

    private func loadMessages() {
        guard let url = URL(string: "https://jetong.ru/messenger/receive.php") else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                if let string = String(data: data, encoding: .utf8) {
                    let messages = string.components(separatedBy: "\n").filter { !$0.isEmpty }
            let formattedMessages = messages.map { "• \($0)" }.joined(separator: "\n")
            self?.messagesLabel.text = formattedMessages
            // Прокрутка к последнему сообщению
            if let labelHeight = self?.messagesLabel.frame.size.height,
               let scrollHeight = self?.scrollView.frame.size.height {
                let bottomOffset = CGPoint(x: 0, y: max(labelHeight - scrollHeight, 0))
                self?.scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
        task.resume()
    }

    private func startAutoRefresh() {
        refreshTimer?.invalidate() // Останавливаем предыдущий таймер, если есть
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.loadMessages()
        }
    }
}
