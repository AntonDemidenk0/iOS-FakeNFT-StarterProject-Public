import UIKit
import Kingfisher

protocol ProfileNFTCellDelegate: AnyObject {
    func didTapLikeButton(_ cell: ProfileNFTCollectionCell, nft: Nft)
    func didTapAddToCartButton(_ cell: ProfileNFTCollectionCell, nft: Nft)
}

final class ProfileNFTCollectionCell: UICollectionViewCell {
    
    static let identifier = "ProfileNFTCollectionCell"
    weak var delegate: ProfileNFTCellDelegate?
    private var nft: Nft?
    private var cart: Order?
    private let service = ProfileNFTService.shared
    private var profile: Profile?
    
    // MARK: - UI Components
    
    private lazy var nftImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let nameLabel = ProfileNFTCollectionCell.createLabel(fontSize: 17, weight: .bold)
    private let priceLabel = ProfileNFTCollectionCell.createLabel(fontSize: 10, weight: .light)
    
    private let ratingStarsView: RatingStarsView = {
        let view = RatingStarsView()
        return view
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "emptyHeart"), for: .normal)
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var addToCartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addToCart"), for: .normal)
        button.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
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
        [nftImage, nameLabel, priceLabel, ratingStarsView, addToCartButton, likeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
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
    
    func configure(nft: Nft, cart: Order, profile: Profile) {
        self.nft = nft
        nftImage.kf.indicatorType = .activity
        
        guard let urlString = nft.images.first, let url = URL(string: urlString) else {
            print("Invalid URL for image")
            return
        }
        
        nftImage.kf.setImage(with: url) { [weak self] result in
            switch result {
            case .success:
                self?.nftImage.kf.indicatorType = .none
            case .failure(let error):
                print("Error loading image: \(error.localizedDescription)")
            }
        }
        
        nameLabel.text = ProfileNFTCollectionCell.limitedText(nft.name, limit: 9)
        priceLabel.text = "\(nft.price) ETH"
        ratingStarsView.rating = nft.rating
        
        if profile.likes.contains(nft.id) {
            self.likeButton.setImage(UIImage(named: "filledHeart"), for: .normal)
        } else {
            self.likeButton.setImage(UIImage(named: "emptyHeart"), for: .normal)
        }
        
        if cart.nfts.contains(nft.id) {
            addToCartButton.setImage(UIImage(named: "deleteFromCart"), for: .normal)
        } else {
            addToCartButton.setImage(UIImage(named: "addToCart"), for: .normal)
        }
    }
    
    func setLiked(isLiked: Bool) {
        let like = isLiked ? UIImage(named: "emptyHeart") : UIImage(named: "filledHeart")
        DispatchQueue.main.async {
            self.likeButton.setImage(like, for: .normal)
        }
    }
    
    func setAdded(isAdded: Bool) {
        let add = isAdded ? UIImage(named: "deleteFromCart") : UIImage(named: "addToCart")
        DispatchQueue.main.async {
            self.addToCartButton.setImage(add, for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @objc private func likeButtonTapped() {
        guard let nft = self.nft else { return }
        service.setCurrentNFT(nft)
        delegate?.didTapLikeButton(self, nft: nft)
        
    }
    
    @objc private func addToCartButtonTapped() {
        guard let nft = self.nft else { return }
        service.setCurrentNFT(nft)
        delegate?.didTapAddToCartButton(self, nft: nft)
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
