import UIKit
import Kingfisher

final class RatingCell: UICollectionViewCell {
    
    static let identifier = "RatingTableViewCell"
    
    // MARK: - UI Elements
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 14
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let nftCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.backgroundColor = .segmentInactive
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(indexPath: IndexPath, person: Person) {
        ratingLabel.text = "\(indexPath.row + 1)"
        avatarImage.kf.setImage(with: URL(string: person.avatar))
        nameLabel.text = person.name.limited(to: 16)
        nftCountLabel.text = "\(person.nfts.count)"
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        contentView.addSubview(ratingLabel)
        contentView.addSubview(cellView)
        [avatarImage, nameLabel, nftCountLabel].forEach { cellView.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            ratingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            ratingLabel.heightAnchor.constraint(equalToConstant: 20),
            ratingLabel.widthAnchor.constraint(equalToConstant: 27),
            
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cellView.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 8),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            avatarImage.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
            avatarImage.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 16),
            avatarImage.heightAnchor.constraint(equalToConstant: 28),
            avatarImage.widthAnchor.constraint(equalToConstant: 28),
            
            nameLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 8),
            
            nftCountLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
            nftCountLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -16)
        ])
    }
}

extension String {
    // MARK: - String Helper
    
    func limited(to length: Int) -> String {
        return count > length ? String(prefix(15)) + "..." : self
    }
}
