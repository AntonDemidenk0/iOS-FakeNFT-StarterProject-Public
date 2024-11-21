import UIKit
import ProgressHUD

final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let statisticService = StatisticService.shared
    private var observer: NSObjectProtocol?
    private var isLoadingData = false
    private var objects: [Person] = []
    
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
        button.setImage(UIImage(named: "sort"), for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupNavBar()
        observeChanges()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(ratingCollectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            ratingCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            ratingCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ratingCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            ratingCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupNavBar() {
        let customBarButton = UIBarButtonItem(customView: sortButton)
        navigationItem.rightBarButtonItem = customBarButton
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .black
    }
    
    // MARK: - Notification Handling
    
    private func observeChanges() {
        ProgressHUD.show()
        observer = NotificationCenter.default.addObserver(
            forName: StatisticService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.updateCollectionView()
            }
        statisticService.fetchNextPage()
    }
    
    // MARK: - Data Handling
    
    private func updateCollectionView() {
        let oldCount = objects.count
        let newCount = statisticService.users.count
        objects = statisticService.users
        
        if oldCount != newCount {
            ratingCollectionView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                ratingCollectionView.insertItems(at: indexPaths)
            }
        }
        ProgressHUD.dismiss()
    }
}

// MARK: - Extensions

extension StatisticsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RatingCell.identifier, for: indexPath) as? RatingCell else {
            return UICollectionViewCell()
        }
        let person = objects[indexPath.row]
        cell.configure(indexPath: indexPath, person: person)
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
        let person = objects[indexPath.row]
        let profileVC = ProfileInfoView(object: person)
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
