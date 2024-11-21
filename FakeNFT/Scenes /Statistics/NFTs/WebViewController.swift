import UIKit
import WebKit

final class WebViewController: UIViewController {

    // MARK: - Properties
    
    private let urlString: String
    private lazy var progressView: UIProgressView = createProgressView()
    private lazy var webView: WKWebView = createWebView()

    // MARK: - Initializer
    
    init(url: String) {
        self.urlString = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) must be implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadWebContent()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubview(webView)
        view.addSubview(progressView)
    }

    private func createWebView() -> WKWebView {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }

    private func createProgressView() -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = .black
        progressView.isHidden = true
        return progressView
    }
    
    private func loadWebContent() {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
        progressView.setProgress(0.1, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(1.0, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.progressView.isHidden = true
            self.progressView.setProgress(0, animated: false)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView failed to load with error: \(error.localizedDescription)")
        progressView.setProgress(1.0, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.progressView.isHidden = true
            self.progressView.setProgress(0, animated: false)
        }
    }
}
