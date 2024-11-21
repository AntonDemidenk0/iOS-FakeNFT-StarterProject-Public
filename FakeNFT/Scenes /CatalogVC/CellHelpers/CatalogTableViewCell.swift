import UIKit

final class CatalogTableViewCell: UITableViewCell {
    
    // MARK: - Static Properties
    
    static let identifier: String = "CatalogTableViewCell"
    
    // MARK: - UI Elements
   
    private let containerView = UIView()
    private let collectionImageView = UIImageView()
    private let footerView = UIView()
    private let titleLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        containerView.addSubview(collectionImageView)
        containerView.addSubview(activityIndicator)
        containerView.addSubview(footerView)
        footerView.addSubview(titleLabel)
        
        collectionImageView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: collectionImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: collectionImageView.centerYAnchor),
            
            footerView.topAnchor.constraint(equalTo: collectionImageView.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor)
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
