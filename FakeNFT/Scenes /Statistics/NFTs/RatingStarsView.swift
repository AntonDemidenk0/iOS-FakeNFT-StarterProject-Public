import UIKit

final class RatingStarsView: UIStackView {
    
    // MARK: - Properties
    
    var rating: Int = 0 {
        didSet { updateRating() }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        spacing = 2
        distribution = .fillEqually
        
        for _ in 1...5 {
            addArrangedSubview(createStarImageView())
        }
    }
    
    private func updateRating() {
        for (index, subview) in arrangedSubviews.enumerated() {
            guard let starImageView = subview as? UIImageView else { continue }
            starImageView.image = UIImage(named: index < rating ? "filledStar" : "emptyStar")
        }
    }
    
    private func createStarImageView() -> UIImageView {
        let starImageView = UIImageView(image: UIImage(named: "emptyStar"))
        starImageView.contentMode = .scaleAspectFit
        return starImageView
    }
}
