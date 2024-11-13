import UIKit

final class ProfileNFTCollectionCell: UICollectionViewCell {
    
    static let identifier = "ProfileNFTCollectionCell"
    
    private lazy var nftImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addSubview(likeButton)
        return imageView
    }()
    
    private let nameLabel = ProfileNFTCollectionCell.createLabel(fontSize: 17, weight: .bold)
    private let priceLabel = ProfileNFTCollectionCell.createLabel(fontSize: 10, weight: .medium)
    
    private let ratingStarsView: RatingStarsView = {
        let view = RatingStarsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var addToCart: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    private func setViews() {
        [nftImage, nameLabel, priceLabel, ratingStarsView, addToCart].forEach(contentView.addSubview)
        setConstraints()
    }
    
    private func setConstraints() {
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
            
            addToCart.heightAnchor.constraint(equalToConstant: 40),
            addToCart.widthAnchor.constraint(equalToConstant: 40),
            addToCart.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            addToCart.topAnchor.constraint(equalTo: ratingStarsView.bottomAnchor, constant: 4)
        ])
    }
    
    @objc private func likeButtonTapped() {
        let currentImage = likeButton.image(for: .normal)
        let newImageName = (currentImage == UIImage(named: "filledHeart")) ? "emptyHeart" : "filledHeart"
        likeButton.setImage(UIImage(named: newImageName), for: .normal)
    }
    
    func set(nft: NFTModel) {
        nftImage.image = UIImage(named: nft.image)
        nameLabel.text = nft.name
        priceLabel.text = "\(nft.price) ETH"
        ratingStarsView.rating = nft.rating
        
        likeButton.setImage(UIImage(named: "emptyHeart"), for: .normal)
        addToCart.setImage(UIImage(named: "cart"), for: .normal)
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func createLabel(fontSize: CGFloat, weight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: fontSize, weight: weight)
        return label
    }
}
