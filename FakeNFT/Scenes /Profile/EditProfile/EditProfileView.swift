//
//  EditProfileView.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 12.11.24..
//

import UIKit

final class EditProfileView: UIView {
    
    var closeTapped: (() -> Void)?
    var avatarTapped: (() -> Void)?
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        
        let image = UIImage(named: "cross")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "YBlackColor")
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var profileAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var profileAvatarButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 35
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(avatarImageTapped), for: .touchUpInside)
        
        button.backgroundColor = UIColor(named: "YBlackColor")?.withAlphaComponent(0.6)
        
        button.setTitle(NSLocalizedString("ChangePhoto", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        
        return button
    }()
    
    private lazy var loadImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 250, height: 44)
        button.isHidden = true
        button.setTitle(NSLocalizedString("LoadImage", comment: ""), for: .normal)
        button.setTitleColor(UIColor(named: "YBlackColor"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(loadImageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Name", comment: "")
        label.textColor = UIColor(named: "YBlackColor")
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    lazy var nameTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.layer.cornerRadius = 12
        textView.backgroundColor = UIColor(named: "LightGrayColor")
        textView.textContainerInset = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        textView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return textView
    }()
    
    private lazy var userInfoLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Description", comment: "")
        label.textColor = UIColor(named: "YBlackColor")
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    lazy var infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.layer.cornerRadius = 12
        textView.backgroundColor = UIColor(named: "LightGrayColor")
        textView.textContainerInset = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        textView.heightAnchor.constraint(equalToConstant: 132).isActive = true
        return textView
    }()
    
    private lazy var userSiteLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("WebSite", comment: "")
        label.textColor = UIColor(named: "YBlackColor")
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    lazy var siteTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.layer.cornerRadius = 12
        textView.backgroundColor = UIColor(named: "LightGrayColor")
        textView.textContainerInset = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        textView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        [closeButton, profileAvatar, profileAvatarButton, loadImageButton, nameLabel, nameTextView, userInfoLabel, infoTextView, userSiteLabel, siteTextView].forEach { addSubview($0) }
    }
    
    private func setupConstraints() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        profileAvatar.translatesAutoresizingMaskIntoConstraints = false
        profileAvatarButton.translatesAutoresizingMaskIntoConstraints = false
        loadImageButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextView.translatesAutoresizingMaskIntoConstraints = false
        userInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoTextView.translatesAutoresizingMaskIntoConstraints = false
        userSiteLabel.translatesAutoresizingMaskIntoConstraints = false
        siteTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            
            profileAvatar.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileAvatar.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 22),
            profileAvatar.widthAnchor.constraint(equalToConstant: 70),
            profileAvatar.heightAnchor.constraint(equalToConstant: 70),
            
            profileAvatarButton.centerXAnchor.constraint(equalTo: profileAvatar.centerXAnchor),
            profileAvatarButton.centerYAnchor.constraint(equalTo: profileAvatar.centerYAnchor),
            profileAvatarButton.widthAnchor.constraint(equalToConstant: 70),
            profileAvatarButton.heightAnchor.constraint(equalToConstant: 70),
            
            loadImageButton.topAnchor.constraint(equalTo: profileAvatar.bottomAnchor, constant: 4),
            loadImageButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: profileAvatar.bottomAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            nameTextView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            userInfoLabel.topAnchor.constraint(equalTo: nameTextView.bottomAnchor, constant: 24),
            userInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            userInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            infoTextView.topAnchor.constraint(equalTo: userInfoLabel.bottomAnchor, constant: 8),
            infoTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            infoTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            userSiteLabel.topAnchor.constraint(equalTo: infoTextView.bottomAnchor, constant: 24),
            userSiteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            userSiteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            siteTextView.topAnchor.constraint(equalTo: userSiteLabel.bottomAnchor, constant: 8),
            siteTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            siteTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func closeButtonTapped() {
        closeTapped?()
    }
    
    @objc private func loadImageButtonTapped() {
        avatarTapped?()
    }
    
    @objc private func avatarImageTapped() {
        if loadImageButton.isHidden == true {
            loadImageButton.isHidden = false
        } else {
            loadImageButton.isHidden = true
        }
    }
}
