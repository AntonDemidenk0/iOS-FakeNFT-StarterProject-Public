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

final class ProfileView: UIViewController {
    
    private let servicesAssembly: ServicesAssembly
    
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
    
    private lazy var profileAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Mock Name"
        label.textColor = UIColor(named: "YBlackColor")
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private lazy var userWebSiteLabel: UILabel = {
        let label = UILabel()
        label.text = "https://practicum.yandex.ru"
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 15)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnWebsiteLabel))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
    
    private lazy var profileInfoLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("NoInformation", comment: "")
        label.textColor = UIColor(named: "YBlackColor")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 4
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var profileTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.rowHeight = 54
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        return tableView
    }()
    
    private lazy var profileContainerView: UIView = {
        let view = UIView()
        return view
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
        
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupLayout()
        ProgressHUD.show()
        loadProfile()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editProfileButton)
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            editProfileButton.widthAnchor.constraint(equalToConstant: 44),
            editProfileButton.heightAnchor.constraint(equalToConstant: 44),
            editProfileButton.trailingAnchor.constraint(equalTo: navigationItem.rightBarButtonItem!.customView!.trailingAnchor, constant: -9),
            editProfileButton.centerYAnchor.constraint(equalTo: navigationItem.rightBarButtonItem!.customView!.centerYAnchor)
        ])
    }
    
    private func setupLayout() {
        
        view.addSubview(profileContainerView)
        profileContainerView.addSubview(profileAvatar)
        profileContainerView.addSubview(userNameLabel)
        profileContainerView.addSubview(profileInfoLabel)
        profileContainerView.addSubview(userWebSiteLabel)
        view.addSubview(profileTableView)
        
        profileContainerView.translatesAutoresizingMaskIntoConstraints = false
        profileAvatar.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        userWebSiteLabel.translatesAutoresizingMaskIntoConstraints = false
        profileTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            profileAvatar.topAnchor.constraint(equalTo: profileContainerView.topAnchor),
            profileAvatar.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor),
            profileAvatar.widthAnchor.constraint(equalToConstant: 70),
            profileAvatar.heightAnchor.constraint(equalToConstant: 70),
            
            userNameLabel.centerYAnchor.constraint(equalTo: profileAvatar.centerYAnchor),
            userNameLabel.centerXAnchor.constraint(equalTo: profileContainerView.centerXAnchor),
            
            profileInfoLabel.topAnchor.constraint(equalTo: profileAvatar.bottomAnchor, constant: 20),
            profileInfoLabel.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor),
            profileInfoLabel.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor),
            
            userWebSiteLabel.topAnchor.constraint(equalTo: profileInfoLabel.bottomAnchor, constant: 12),
            userWebSiteLabel.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor),
            userWebSiteLabel.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor),
            userWebSiteLabel.bottomAnchor.constraint(equalTo: profileContainerView.bottomAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            profileTableView.topAnchor.constraint(equalTo: profileContainerView.bottomAnchor, constant: 40),
            profileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileTableView.heightAnchor.constraint(equalToConstant: 54 * 3)
        ])
    }
    
    private func updateUI(with profile: Profile) {
        userNameLabel.text = profile.name
        
        if let avatarURLString = profile.avatar, let url = URL(string: avatarURLString) {
            profileAvatar.kf.setImage(with: url, placeholder: UIImage(systemName: "person.crop.circle"))
        } else {
            profileAvatar.image = UIImage(systemName: "person.crop.circle")
        }
        
        if let website = profile.website {
            userWebSiteLabel.text = website
        } else {
            userWebSiteLabel.isHidden = true
        }
        
        profileInfoLabel.text = profile.description ?? NSLocalizedString("NoInformation", comment: "")
    }
    
    // MARK: - Actions
    
    @objc private func editProfileTapped() {
    }
    
    @objc private func didTapOnWebsiteLabel() {
        guard let urlString = userWebSiteLabel.text,
              let url = URL(string: urlString) else { return }
        
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

// MARK: - UITableViewDataSource
extension ProfileView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("MyNFT", comment: "")
        case 1:
            cell.textLabel?.text = NSLocalizedString("Favorites", comment: "")
        case 2:
            cell.textLabel?.text = NSLocalizedString("AboutDeveloper", comment: "")
        default:
            break
        }
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        cell.textLabel?.textColor = UIColor(named: "YBlackColor")
        
        let chevronImage = UIImage(systemName: "chevron.forward", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .medium))?.withRenderingMode(.alwaysTemplate)
        let chevronImageView = UIImageView(image: chevronImage)
        
        cell.accessoryView = chevronImageView
        cell.tintColor = UIColor(named: "YBlackColor")
        
        
        return cell
    }
}

extension ProfileView {
    private func loadProfile() {
        servicesAssembly.profileService.loadProfile { [weak self] result in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                switch result {
                case .success(let profile):
                    self?.updateUI(with: profile)
                    print("\(profile.name), \(profile.avatar), \(profile.website)")
                case .failure(let error):
                    print("error \(error)")
                }
            }
        }
    }
}

extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}
