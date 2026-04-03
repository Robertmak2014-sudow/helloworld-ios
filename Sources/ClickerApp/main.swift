import UIKit
import NetworkExtension

enum ProxyProtocol: String, Codable {
    case vless, vmess, shadowsocks, trojan, socks, http
}

struct V2RayConfig: Codable {
    let name: String
    let `protocol`: ProxyProtocol
    let address: String
    let port: Int
    let id: String
    let flow: String?
    let method: String?
    let password: String?
    let security: String?
    let sni: String?
    let fingerprint: String?
    let alterId: Int?
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var profiles: [V2RayConfig] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController(profiles: &profiles)
        window?.makeKeyAndVisible()
        return true
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var profiles: [V2RayConfig]
    private let tableView = UITableView()

    init(profiles: inout [V2RayConfig]) {
        self.profiles = profiles
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showInitialMessage()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "V2Ray Client"

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSubscription))
        navigationItem.rightBarButtonItem = addButton

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func showInitialMessage() {
        let label = UILabel()
        label.text = "Нажмите '+' для добавления подписки"
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func addSubscription() {
        let alert = UIAlertController(title: "Add Subscription", message: "Enter subscription URL", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "https://example.com/sub" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            if let urlString = alert.textFields?.first?.text, let url = URL(string: urlString) {
                self.fetchSubscription(from: url)
            }
        })
        present(alert, animated: true)
    }

    private func fetchSubscription(from url: URL) {
        var request = URLRequest(url: url)
        request.setValue("Happ/1.0 (iPhone; iOS 16.0; Scale/2.00)", forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.showError("Ошибка загрузки: \(error?.localizedDescription ?? "Неизвестная ошибка")")
                }
                return
            }

            let base64String = String(data: data, encoding: .utf8) ?? ""
            if base64String.hasPrefix("vless://") || base64String.hasPrefix("ss://") {
                let configs = self?.parseProxyLinks(base64String)
                DispatchQueue.main.async {
                    self?.profiles.append(contentsOf: configs ?? [])
            self?.tableView.reloadData()
                }
            } else {
                guard let decodedData = Data(base64Encoded: base64String),
                      let jsonString = String(data: decodedData, encoding: .utf8) else {
                    DispatchQueue.main.async {
                self?.showError("Неверный формат данных")
            }
            return
                }
                do {
                    let configs = try JSONDecoder().decode([V2RayConfig].self, from: Data(jsonString.utf8))
            DispatchQueue.main.async {
                self?.profiles.append(contentsOf: configs)
                self?.tableView.reloadData()
            }
                } catch {
                    DispatchQueue.main.async {
            self?.showError("Ошибка парсинга: \(error.localizedDescription)")
            }
                }
            }
        }.resume()
    }

    private func parseProxyLinks(_ links: String) -> [V2RayConfig] {
        return []
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let profile = profiles[indexPath.row]
        cell.textLabel?.text = "\(profile.name) (\(profile.`protocol`.rawValue))"
        cell.detailTextLabel?.text = "\(profile.address):\(profile.port)"
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let profile = profiles[indexPath.row]
        print("Connecting to \(profile.`protocol`.rawValue): \(profile.name)")
    }
}
