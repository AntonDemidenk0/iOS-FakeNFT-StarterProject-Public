//
//  CartItemCell.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 11.11.2024.
//

import UIKit
import Kingfisher

final class CartItemCell: UITableViewCell {
    
    static let reuseIdentifier = "CartItemCell"
    
    private var deleteAction: (() -> Void)?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var innerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var ratingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var priceTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.text = "Цена"
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .delete), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
        
    @objc private func deleteButtonTapped() {
        deleteAction?()
    }
    
    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        containerView.addSubview(innerContainerView)
        innerContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            innerContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            innerContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            innerContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            innerContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        innerContainerView.addSubview(itemImageView)
        itemImageView.addSubview(loadingIndicator)
        innerContainerView.addSubview(nameLabel)
        innerContainerView.addSubview(ratingImageView)
        innerContainerView.addSubview(priceTitleLabel)
        innerContainerView.addSubview(priceLabel)
        innerContainerView.addSubview(deleteButton)
        
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingImageView.translatesAutoresizingMaskIntoConstraints = false
        priceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            itemImageView.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor),
            itemImageView.topAnchor.constraint(equalTo: innerContainerView.topAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 108),
            itemImageView.heightAnchor.constraint(equalToConstant: 108),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: itemImageView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: itemImageView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: innerContainerView.topAnchor, constant: 8),
            
            ratingImageView.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 20),
            ratingImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ratingImageView.widthAnchor.constraint(equalToConstant: 68),
            ratingImageView.heightAnchor.constraint(equalToConstant: 12),
            
            priceTitleLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 20),
            priceTitleLabel.topAnchor.constraint(equalTo: ratingImageView.bottomAnchor, constant: 12),
            
            priceLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 20),
            priceLabel.topAnchor.constraint(equalTo: priceTitleLabel.bottomAnchor, constant: 2),
            
            deleteButton.centerYAnchor.constraint(equalTo: innerContainerView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: innerContainerView.trailingAnchor, constant: 0),
            deleteButton.widthAnchor.constraint(equalToConstant: 40),
            deleteButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with item: CartItem, onDelete: @escaping () -> Void) {
        nameLabel.text = item.name
        priceLabel.text = "\(item.price)"
        
        self.deleteAction = onDelete
        
        let placeholderImage = UIImage(systemName: "photo")
        loadingIndicator.startAnimating()
        
        if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
            itemImageView.kf.setImage(
                with: url,
                placeholder: placeholderImage,
                options: [
                    .transition(.fade(0.2)),
                    .memoryCacheExpiration(.days(1))
                ],
                progressBlock: nil
            ) { [weak self] result in
                self?.loadingIndicator.stopAnimating()
                if case .failure = result {
                    self?.itemImageView.image = placeholderImage
                }
            }
        } else {
            itemImageView.image = placeholderImage
            loadingIndicator.stopAnimating()
        }
        
        updateStars(for: item.rating)
    }
    
    private func updateStars(for rating: Int) {
        guard rating >= 0 && rating <= 5 else { return }
        
        let imageName: String
        switch rating {
        case 0: imageName = "stars_zero"
        case 1: imageName = "stars_one"
        case 2: imageName = "stars_two"
        case 3: imageName = "stars_three"
        case 4: imageName = "stars_four"
        case 5: imageName = "stars_five"
        default: return
        }
        
        ratingImageView.image = UIImage(named: imageName)
    }
}
