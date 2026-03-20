import UIKit

// Создаём окно и контроллер
let window = UIWindow(frame: UIScreen.main.bounds)
let rootViewController = UIViewController()

// Элементы интерфейса
let scrollView = UIScrollView()
let messagesLabel = UILabel()
let messageTextField = UITextField()
let sendButton = UIButton(type: .system)

var refreshTimer: Timer?

// Функция настройки интерфейса
func setupUI() {
    // Настраиваем корневой контроллер
    rootViewController.view.backgroundColor = .white
    
    // Scroll View для сообщений
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    rootViewController.view.addSubview(scrollView)
    
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
    messageTextField.delegate = messageTextFieldDelegate  // Устанавливаем делегата
    rootViewController.view.addSubview(messageTextField)
    
    // Кнопка отправки
    sendButton.setTitle("Отправить", for: .normal)
    sendButton.layer.cornerRadius = 8
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    sendButton.addTarget(nil, action: #selector(sendMessage), for: .touchUpInside)
    rootViewController.view.addSubview(sendButton)
    
    // Настройка Auto Layout
    NSLayoutConstraint.activate([
        // ScrollView: верхняя часть экрана (70 % высоты)
        scrollView.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
        scrollView.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
        scrollView.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor),
        scrollView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -8),
        scrollView.heightAnchor.constraint(equalTo: rootViewController.view.heightAnchor, multiplier: 0.7),
        
        // Messages Label внутри ScrollView
        messagesLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
        messagesLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
        messagesLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
        messagesLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
        messagesLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -16),
        
        // TextField внизу экрана: уменьшенные размеры
        messageTextField.centerXAnchor.constraint(equalTo: rootViewController.view.centerXAnchor),
        messageTextField.bottomAnchor.constraint(equalTo: rootViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        messageTextField.heightAnchor.constraint(equalToConstant: 44),
        messageTextField.widthAnchor.constraint(equalTo: rootViewController.view.widthAnchor, multiplier: 0.7),  // 70 % ширины экрана
        
        // Кнопка справа от TextField
        sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 8),
        sendButton.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor, constant: -16),
        sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
        sendButton.widthAnchor.constraint(equalToConstant: 80),
        sendButton.heightAnchor.constraint(equalToConstant: 40)
    ])
}

// Делегат для обработки нажатия Enter
class MessageTextFieldDelegate: NSObject, UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true  // Скрываем клавиатуру после отправки
    }
}
let messageTextFieldDelegate = MessageTextFieldDelegate()

@objc func sendMessage() {
    guard let text = messageTextField.text, !text.isEmpty else { return }
    let urlString = "https://jetong.ru/messenger/send.php?text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
    guard let url = URL(string: urlString) else { return }
    
    URLSession.shared.dataTask(with: url) { _, _, error in
        DispatchQueue.main.async {
            if error == nil {
                self.messageTextField.text = ""
                self.loadMessages()
            }
        }
    }.resume()
}

func loadMessages() {
    let url = URL(string: "https://jetong.ru/messenger/receive.php")!
    URLSession.shared.dataTask(with: url) { data, _, error in
        DispatchQueue.main.async {
            if let data = data, let string = String(data: data, encoding: .utf8) {
                let messages = string.components(separatedBy: "\n").filter { !$0.isEmpty }
                let formattedMessages = messages.map { "• \($0)" }.joined(separator: "\n")
                messagesLabel.text = formattedMessages
                // Прокрутка вниз к последнему сообщению
                let bottomOffset = CGPoint(x: 0, y: max(messagesLabel.frame.size.height - scrollView.frame.size.height, 0))
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }.resume()
}

func startAutoRefresh() {
    refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
        loadMessages()
    }
}

// Запуск приложения
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window.rootViewController = rootViewController
    window.makeKeyAndVisible()
    setupUI()
    startAutoRefresh()
    loadMessages()  // Первоначальная загрузка сообщений
    return true
}

// Точка входа
UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(
        to: UnsafeMutablePointer<Int8>.self,
        capacity: Int(CommandLine.argc)
    ),
    nil,
    NSStringFromClass(UIApplication.self)
)
