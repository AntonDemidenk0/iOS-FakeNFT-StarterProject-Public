//
//  CatalogTableViewCell.swift
//  FakeNFT
//
//  Created by GiyaDev on 09.11.2024.
//

import UIKit

final class CatalogTableViewCell: UITableViewCell {
    
    static let identifier: String = "CatalogTableViewCell"
    
    private let collectionImageView = UIImageView()
    private let footerView = UIView()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadImage(from urlString: String) {
        if let cachedImage = ImageCache.shared.object(forKey: NSString(string: urlString)) {
            collectionImageView.image = cachedImage
            return
        }

        collectionImageView.image = UIImage(named: "placeholder")
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Failed to load image: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to decode image data")
                return
            }
            ImageCache.shared.setObject(image, forKey: NSString(string: urlString)) // Сохранение в кэш
            DispatchQueue.main.async {
                self?.collectionImageView.image = image
            }
        }.resume()
    }

    private func setupLayout() {
        contentView.addSubview(collectionImageView)
        contentView.addSubview(footerView)
        footerView.addSubview(titleLabel)

        collectionImageView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            footerView.topAnchor.constraint(equalTo: collectionImageView.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -8)
        ])

        collectionImageView.layer.cornerRadius = 12
        collectionImageView.clipsToBounds = true
        collectionImageView.contentMode = .scaleAspectFill

        footerView.backgroundColor = .systemBackground
        footerView.layer.cornerRadius = 12
        footerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label
    }

    func configure(with name: String, nftCount: Int, imageUrl: String) {
        let capitalizedName = name.prefix(1).uppercased() + name.dropFirst()
        titleLabel.text = "\(capitalizedName) (\(nftCount))"
        loadImage(from: imageUrl)
    }
}
