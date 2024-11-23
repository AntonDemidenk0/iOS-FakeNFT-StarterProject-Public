

import UIKit

final class NFTCollectionViewCell: UICollectionViewCell, LoadingView {
    // MARK: - Static Properties
    static let identifier = "NFTCollectionViewCell"
    weak var delegate: NFTCollectionViewCellDelegate?
    
    // MARK: - Properties
     private var isInCart = false {
         didSet {
             updateCartButtonState()
         }
     }
    
    private var isFavorite = false {
        didSet {
            updateFavoriteButtonState()
        }
    }
    
    func setCartState(_ inCart: Bool) {
        isInCart = inCart
    }

    // MARK: - UI Elements
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "noActive"), for: .normal)
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()

    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .label
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .center 
        return stackView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()
    
    private let cartButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "emptyBasket"), for: .normal)
        button.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup
    
    private func setupLayout() {
        contentView.addSubview(nftImageView)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(ratingStackView)

        let nameAndPriceStack = UIStackView(arrangedSubviews: [nameLabel, priceLabel])
        nameAndPriceStack.translatesAutoresizingMaskIntoConstraints = false
        nameAndPriceStack.axis = .vertical
        nameAndPriceStack.spacing = 4

        let nameAndCartStack = UIStackView(arrangedSubviews: [nameAndPriceStack, cartButton])
        nameAndCartStack.translatesAutoresizingMaskIntoConstraints = false
        nameAndCartStack.axis = .horizontal
        nameAndCartStack.spacing = 8
        nameAndCartStack.alignment = .center

        contentView.addSubview(nameAndCartStack)

        NSLayoutConstraint.activate([
            // NFT Image
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),

            activityIndicator.centerYAnchor.constraint(equalTo: nftImageView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: nftImageView.centerXAnchor),

            // Favorite Button
            favoriteButton.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 12),
            favoriteButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: -10),
            favoriteButton.widthAnchor.constraint(equalToConstant: 21),
            favoriteButton.heightAnchor.constraint(equalToConstant: 18),

            // Rating Stack
            ratingStackView.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 4),
            ratingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),

            // Name and Cart Stack
            nameAndCartStack.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 8),
            nameAndCartStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameAndCartStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Name Label (внутри стека)
            nameLabel.leadingAnchor.constraint(equalTo: nameAndPriceStack.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: nameAndPriceStack.trailingAnchor),

            // Cart Button
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Configure Cell
    
    private func setupRating(rating: Int) {
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let maxStars = 5
        for i in 0..<maxStars {
            let starImageView = UIImageView()
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.image = UIImage(systemName: "star.fill")
            starImageView.tintColor = i < rating ? .systemYellow : .lightGray
            NSLayoutConstraint.activate([
                starImageView.widthAnchor.constraint(equalToConstant: 12),
                starImageView.heightAnchor.constraint(equalTo: starImageView.widthAnchor)
            ])
            ratingStackView.addArrangedSubview(starImageView)
        }
    }
    
    // MARK: - State Updates
    private func updateCartButtonState() {
        let imageName = isInCart ? "fullBasket" : "emptyBasket"
        cartButton.setImage(UIImage(named: imageName), for: .normal)
    }

    private func updateFavoriteButtonState() {
        let imageName = isFavorite ? "active" : "noActive"
        favoriteButton.setImage(UIImage(named: imageName), for: .normal)
    }

    
    // MARK: - Button Actions
    @objc
    private func cartButtonTapped() {
        isInCart.toggle()
        delegate?.nftCollectionViewCellDidToggleCart(self)
    }

    @objc
    private func favoriteButtonTapped() {
        isFavorite.toggle()
        delegate?.nftCollectionViewCellDidToggleFavorite(self)
    }

    // MARK: - Configure Cell
    
    func setFavoriteState(_ isFavorite: Bool) {
        self.isFavorite = isFavorite
    }

    func configure(with nft: Nft, image: UIImage?) {
        let firstWord = nft.name.split(separator: " ").first.map(String.init) ?? nft.name
        nameLabel.text = firstWord
        priceLabel.text = nft.price > 0 ? "\(nft.price) ETH" : "Loading..."
        
        if let image = image {
            nftImageView.image = image
            hideLoading()
            favoriteButton.isHidden = false
            cartButton.isHidden = false
            ratingStackView.isHidden = false
            setupRating(rating: nft.rating)
        } else {
            nftImageView.image = UIImage(named: "placeholder")
            showLoading()
            favoriteButton.isHidden = true
            cartButton.isHidden = true
            ratingStackView.isHidden = true
        }
    }
}
