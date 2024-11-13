import UIKit

final class StatisticsViewController: UIViewController {
    
    private lazy var ratingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(RatingCell.self, forCellWithReuseIdentifier: RatingCell.identifier)
        collection.dataSource = self
        collection.delegate = self
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .black
        if let sortImage = UIImage(named: "sort") {
            button.setImage(sortImage, for: .normal)
        }
        return button
    }()
    
    var objects: [Person] = [
        Person(name: "Lea", image: "lea", webSite: "https://ya.ru", rating: 1, nftCount: 2, description: "Дизайнер из Казани, люблю цифровое искусство \nи бейглы. В моей коллекции уже 100+ NFT,\nи еще больше — на моём сайте. Открыт\nк коллаборациям.", nft: [
            NFTModel(image: "mok", name: "Archie", price: 1.78, isLiked: false, rating: 3, isAdded: false),
            NFTModel(image: "mok2", name: "Greena", price: 1.98, isLiked: true, rating: 2, isAdded: false)
        ]),
        Person(name: "Mads", image: "mads", webSite: "https://google.com", rating: 2, nftCount: 0, description: "Дизайнер из Казани, люблю цифровое искусство \nи бейглы. В моей коллекции уже 100+ NFT,\nи еще больше — на моём сайте. Открыт\nк коллаборациям.", nft: [])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        setConstraints()
        setNavBar()
    }
    
    private func setViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(ratingCollectionView)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            ratingCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            ratingCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ratingCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            ratingCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
    }
    
    private func setNavBar() {
        let custom = UIBarButtonItem(customView: sortButton)
        navigationItem.rightBarButtonItem = custom
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .black
    }
}

extension StatisticsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RatingCell.identifier, for: indexPath) as? RatingCell else {
            return UICollectionViewCell()
        }
        let person = objects[indexPath.row]
        cell.configure(with: person)
        return cell
    }
}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension StatisticsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = objects[indexPath.row]
        let profileVC = ProfileInfoView(object: object)
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
