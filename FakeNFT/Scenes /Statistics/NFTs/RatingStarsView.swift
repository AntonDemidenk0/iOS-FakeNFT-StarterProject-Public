import UIKit

final class RatingStarsView: UIStackView {
    
    var rating: Int = 0 {
        didSet { updateRating() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        spacing = 2
        distribution = .fillEqually
        (1...5).forEach { _ in
            let starImageView = UIImageView(image: UIImage(named: "emptyStar"))
            starImageView.contentMode = .scaleAspectFit
            addArrangedSubview(starImageView)
        }
    }
    
    private func updateRating() {
        for (index, subview) in arrangedSubviews.enumerated() {
            (subview as? UIImageView)?.image = UIImage(named: index < rating ? "filledStar" : "emptyStar")
        }
    }
}
