import UIKit

final class ProfileNFTCollectionCell: UICollectionViewCell {
    
    static let identifier = "ProfileNFTCollectionCell"
    
    // MARK: - UI Components
    
    private lazy var nftImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let nameLabel = ProfileNFTCollectionCell.createLabel(fontSize: 17, weight: .bold)
    private let priceLabel = ProfileNFTCollectionCell.createLabel(fontSize: 10, weight: .light)
    
    private let ratingStarsView: RatingStarsView = {
        let view = RatingStarsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "emptyHeart"), for: .normal)
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var addToCartButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "cart"), for: .normal)
        return button
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) must be implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        [nftImage, nameLabel, priceLabel, ratingStarsView, addToCartButton, likeButton].forEach(contentView.addSubview)
        nftImage.addSubview(likeButton)
    }
    
    private func setupConstraints() {
            NSLayoutConstraint.activate([
                nftImage.topAnchor.constraint(equalTo: contentView.topAnchor),
                nftImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                nftImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                nftImage.heightAnchor.constraint(equalToConstant: (contentView.bounds.height / 5) * 3 ),
                
                likeButton.topAnchor.constraint(equalTo: nftImage.topAnchor),
                likeButton.trailingAnchor.constraint(equalTo: nftImage.trailingAnchor),
                likeButton.heightAnchor.constraint(equalToConstant: 40),
                likeButton.widthAnchor.constraint(equalToConstant: 40),
                
                ratingStarsView.topAnchor.constraint(equalTo: nftImage.bottomAnchor, constant: 8),
                ratingStarsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                ratingStarsView.heightAnchor.constraint(equalToConstant: 12),
                
                nameLabel.topAnchor.constraint(equalTo: ratingStarsView.bottomAnchor, constant: 4),
                nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                
                priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
                priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                
                addToCartButton.heightAnchor.constraint(equalToConstant: 40),
                addToCartButton.widthAnchor.constraint(equalToConstant: 40),
                addToCartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                addToCartButton.topAnchor.constraint(equalTo: ratingStarsView.bottomAnchor, constant: 4)
            ])
        }
    
    // MARK: - Configure
    
    func configure(with nft: NFTModel) {
        nftImage.kf.indicatorType = .activity
        if let url = URL(string: nft.images.first ?? "") {
            nftImage.kf.setImage(with: url) { [weak self] _ in
                self?.nftImage.kf.indicatorType = .none
            }
        }
        
        nameLabel.text = ProfileNFTCollectionCell.limitedText(nft.name, limit: 9)
        priceLabel.text = "\(nft.price) ETH"
        ratingStarsView.rating = nft.rating
    }
    
    // MARK: - Actions
    
    @objc private func likeButtonTapped() {
        let isLiked = likeButton.image(for: .normal) == UIImage(named: "filledHeart")
        let newImageName = isLiked ? "emptyHeart" : "filledHeart"
        likeButton.setImage(UIImage(named: newImageName), for: .normal)
    }
    
    // MARK: - Helpers
    
    private static func createLabel(fontSize: CGFloat, weight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: fontSize, weight: weight)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }
    
    private static func limitedText(_ text: String, limit: Int) -> String {
        return text.count > limit ? String(text.prefix(limit - 3)) + "..." : text
    }
}
