import UIKit

final class RatingCell: UICollectionViewCell {
    
    static let identifier = "RatingTableViewCell"
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 28
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with person: Person) {
        ratingLabel.text = "\(person.rating)"
        avatarImage.image = UIImage(named: person.image)
        nameLabel.text = person.name
        nftCountLabel.text = "\(person.nftCount)"
    }
    
    private func setupViews() {
        contentView.addSubview(ratingLabel)
        contentView.addSubview(cellView)
        [avatarImage, nameLabel, nftCountLabel].forEach { cellView.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            ratingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
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
