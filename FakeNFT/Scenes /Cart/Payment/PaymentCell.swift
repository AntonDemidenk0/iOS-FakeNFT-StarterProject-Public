//
//  PaymentCell.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 12.11.2024.
//

import UIKit
import Kingfisher

final class PaymentCell: UICollectionViewCell {
    static let reuseIdentifier = "PaymentCell"
    
    private let currencyImageView = UIImageView()
    private let titleLabel = UILabel()
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .segmentInactive
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.clipsToBounds = true
        
        currencyImageView.contentMode = .scaleAspectFit
        currencyImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = .textPrimary
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        nameLabel.textColor = .textGreen
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(currencyImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(nameLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            currencyImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            currencyImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            currencyImageView.widthAnchor.constraint(equalToConstant: 36),
            currencyImageView.heightAnchor.constraint(equalToConstant: 36),
            
            titleLabel.leadingAnchor.constraint(equalTo: currencyImageView.trailingAnchor, constant: 4),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            
            nameLabel.leadingAnchor.constraint(equalTo: currencyImageView.trailingAnchor, constant: 4),
            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
        ])
    }
    
    func configure(with model: Currency, isSelected: Bool) {
        currencyImageView.kf.setImage(with: URL(string: model.image))
        titleLabel.text = model.title
        nameLabel.text = model.name
        contentView.layer.borderColor = isSelected ? UIColor.segmentActive.cgColor : UIColor.clear.cgColor
    }
}
