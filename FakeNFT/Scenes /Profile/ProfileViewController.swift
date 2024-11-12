//
//  ProfileView.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 11.11.24..
//

import Foundation
import UIKit
import WebKit
import Kingfisher
import ProgressHUD

final class ProfileViewController: UIViewController {
    
    private let servicesAssembly: ServicesAssembly
    private let profileView = ProfileView()
    
    // MARK: - UI Elements
    private lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: configuration)
        
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "YBlackColor")
        button.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
    
    // MARK: - Initialization
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view = profileView
        profileView.websiteLabelTapped = { [weak self] address in
            self?.didTapOnWebsiteLabel(with: address)
        }
        setupNavigationBar()
        ProgressHUD.show()
        loadProfile()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        let rightBarButton = UIBarButtonItem(customView: editProfileButton)
        navigationItem.rightBarButtonItem = rightBarButton
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            editProfileButton.widthAnchor.constraint(equalToConstant: 44),
            editProfileButton.heightAnchor.constraint(equalToConstant: 44),
            editProfileButton.trailingAnchor.constraint(equalTo: navigationItem.rightBarButtonItem!.customView!.trailingAnchor, constant: -9),
            editProfileButton.centerYAnchor.constraint(equalTo: navigationItem.rightBarButtonItem!.customView!.centerYAnchor)
        ])
    }
    
    // MARK: - Private Methods
    
    private func loadProfile() {
        servicesAssembly.profileService.loadProfile { [weak self] result in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                switch result {
                case .success(let profile):
                    self?.profileView.updateUI(with: profile)
                    print("\(profile.name), \(profile.avatar), \(profile.website)")
                case .failure(let error):
                    print("error \(error)")
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func editProfileTapped() {
    }
    
    private func didTapOnWebsiteLabel(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        let webViewController = UIViewController()
        webViewController.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webViewController.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewController.view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: webViewController.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewController.view.trailingAnchor)
        ])
        
        webViewController.modalPresentationStyle = .pageSheet
        present(webViewController, animated: true, completion: nil)
    }
}


