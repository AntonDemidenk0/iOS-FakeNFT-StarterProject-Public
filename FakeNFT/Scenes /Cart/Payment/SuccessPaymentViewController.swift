//
//  SuccessPaymentViewController.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 13.11.2024.
//

import UIKit

final class SuccessPaymentViewController: UIViewController {
    
    private let onReturnToCatalog: (() -> Void)?
    
    init(onReturnToCatalog: (() -> Void)?) {
        self.onReturnToCatalog = onReturnToCatalog
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    private let successImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "success_image")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Успех! Оплата прошла,\nпоздравляем с покупкой!"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вернуться в каталог", for: .normal)
        button.backgroundColor = UIColor.payButton
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(SuccessPaymentViewController.self, action: #selector(returnToCatalogTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(successImageView)
        view.addSubview(messageLabel)
        view.addSubview(returnButton)
        
        NSLayoutConstraint.activate([
            // Картинка
            successImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            successImageView.widthAnchor.constraint(equalToConstant: 278),
            successImageView.heightAnchor.constraint(equalToConstant: 278),
            
            // Лейбл
            messageLabel.topAnchor.constraint(equalTo: successImageView.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Кнопка
            returnButton.heightAnchor.constraint(equalToConstant: 60),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            returnButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            returnButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    @objc private func returnToCatalogTapped() {
        dismiss(animated: false) {
            self.onReturnToCatalog?()
        }
    }
}
