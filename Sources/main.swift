import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var messagesLabel = UILabel()
    private var messageTextField = UITextField()
    private let refreshTimer: Timer? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        self.window = window

        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .white

        setupUI(rootViewController)
        startAutoRefresh()

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        return true
    }

    private func setupUI(_ viewController: UIViewController) {
        // Scroll View для сообщений
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(scrollView)

        // Label для сообщений
        messagesLabel.numberOfLines = 0
        messagesLabel.textAlignment = .left
        messagesLabel.font = UIFont.systemFont(ofSize: 16)
        messagesLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(messagesLabel)

        // Text Field для ввода
        messageTextField.borderStyle = .roundedRect
        messageTextField.placeholder = "Введите сообщение..."
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(messageTextField)

        // Кнопка «Отправить»
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Отправить", for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(sendButton)

        // Обработчик нажатия кнопки
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)

        // Настройка Auto Layout
        NSLayoutConstraint.activate([
            // ScrollView занимает верхнюю часть экрана
            scrollView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -8),

            // Messages Label внутри ScrollView
            messagesLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            messagesLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
            messagesLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
            messagesLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            messagesLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -16),

            // TextField слева
            messageTextField.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 8),
            messageTextField.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),

            // Кнопка справа от TextField
            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 80),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
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
            let bottomOffset = CGPoint(x: 0, y: self.messagesLabel.frame.size.height - self.scrollView.frame.size.height)
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }.resume()
    }

    private func startAutoRefresh() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.loadMessages()
        }
    }
}
