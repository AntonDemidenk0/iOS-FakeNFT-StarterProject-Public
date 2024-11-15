import UIKit

final class CatalogTableViewCell: UITableViewCell {
    
    // MARK: - Static Properties
    
    static let identifier: String = "CatalogTableViewCell"
    
    // MARK: - UI Elements
    
    private let collectionImageView = UIImageView()
    private let footerView = UIView()
    private let titleLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupLayout() {
        contentView.addSubview(collectionImageView)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(footerView)
        footerView.addSubview(titleLabel)
        
        collectionImageView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: collectionImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: collectionImageView.centerYAnchor),
            
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
        
        activityIndicator.color = .systemBlue
        activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: - Configuration Methods
    
    func configure(with name: String, nftCount: Int) {
        let capitalizedName = name.prefix(1).uppercased() + name.dropFirst()
        titleLabel.text = "\(capitalizedName) (\(nftCount))"
        activityIndicator.startAnimating()
    }
    
    func updateImage(_ result: Result<UIImage, Error>) {
        switch result {
        case .success(let image):
            activityIndicator.stopAnimating()
            collectionImageView.image = image
        case .failure(let error):
            activityIndicator.stopAnimating()
            print("Image loading failed: \(error.localizedDescription)")
        }
    }

}
