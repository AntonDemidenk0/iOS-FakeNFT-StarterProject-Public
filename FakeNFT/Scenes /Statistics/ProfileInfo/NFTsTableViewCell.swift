import UIKit

final class NFTsTableViewCell: UITableViewCell {
    
    // MARK: - Static Properties
    
    static let identifier = "NFTsTableViewCell"
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = createTitleLabel()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) must be implemented")
    }
    
    // MARK: - Configuration Method
    
    func configure(nftCount: Int) {
        titleLabel.text = "Коллекция NFT (\(nftCount))"
    }
    
    // MARK: - Private Methods
    
    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }
    
    private func setupView() {
        contentView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
