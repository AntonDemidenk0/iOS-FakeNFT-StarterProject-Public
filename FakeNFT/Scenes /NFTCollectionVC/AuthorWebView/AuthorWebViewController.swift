import UIKit
import WebKit

final class AuthorWebViewController: UIViewController, WKNavigationDelegate {

    // MARK: - Properties
    private var url: URL?
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()

    // MARK: - Initialization
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWebPage()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let closeButton = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: "Закрыть"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        navigationItem.leftBarButtonItem = closeButton
    }

    private func loadWebPage() {
        guard let url = url else {
            showAlert(
                title: NSLocalizedString("Invalid URL", comment: "Недопустимый URL"),
                message: NSLocalizedString("The provided URL is invalid.", comment: "Указанный URL недопустим.")
            )
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "ОК"), style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showAlert(
            title: NSLocalizedString("Failed to Load", comment: "Ошибка загрузки"),
            message: NSLocalizedString("The website could not be loaded.", comment: "Не удалось загрузить веб-страницу.")
        )
    }
}
