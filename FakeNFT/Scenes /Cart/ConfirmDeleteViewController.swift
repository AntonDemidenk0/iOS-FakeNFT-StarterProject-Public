//
//  ConfirmDeleteViewController.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 11.11.2024.
//

import UIKit
import ProgressHUD

final class ConfirmDeleteViewController: UIViewController {
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Вы уверены, что хотите\nудалить объект из корзины?"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вернуться", for: .normal)
        button.backgroundColor = UIColor.payButton
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.backgroundColor = UIColor.payButton
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(confirmDelete), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let imageUrlString: String
    var onDeleteConfirmed: (() -> Void)?
    
    init(imageUrlString: String) {
        self.imageUrlString = imageUrlString
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBlurBackground()
        setupUI()
        loadImage()
    }
    
    private func setupBlurBackground() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.05) // #FFFFFF0D
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0.9
        
        view.addSubview(backgroundView)
        view.addSubview(blurView)
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(contentView)
        contentView.addSubview(itemImageView)
        contentView.addSubview(messageLabel)
        contentView.addSubview(cancelButton)
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.widthAnchor.constraint(equalToConstant: 262),
            contentView.heightAnchor.constraint(equalToConstant: 220),
            
            itemImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            itemImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 108),
            itemImageView.heightAnchor.constraint(equalToConstant: 108),
            
            messageLabel.topAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: 12),
            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cancelButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 127),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            deleteButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            deleteButton.widthAnchor.constraint(equalToConstant: 127),
            deleteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func confirmDelete() {
        dismiss(animated: true) {
            self.onDeleteConfirmed?()
        }
    }
    
    private func loadImage() {
        guard let url = URL(string: imageUrlString) else { return }
        
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorHUD = .black
        ProgressHUD.colorBackground = .clear
        ProgressHUD.show()
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                guard let data = data, error == nil, let image = UIImage(data: data) else {
                    self?.itemImageView.image = UIImage(systemName: "photo")
                    return
                }
                self?.itemImageView.image = image
            }
        }.resume()
    }
}
