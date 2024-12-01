//
//  WebViewController.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 13.11.2024.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    private let url: URL
    private lazy var webView = WKWebView()
    
    // MARK: - Initializer
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
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadWebPage() {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
