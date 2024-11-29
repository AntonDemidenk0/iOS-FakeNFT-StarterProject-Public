import UIKit
import ProgressHUD

final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let statisticService = StatisticService.shared
    private var isLoadingData = false
    private var persons: [Person] = []
    private var allPersons: [Person] = []
    
    private lazy var ratingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(RatingCell.self, forCellWithReuseIdentifier: RatingCell.identifier)
        collection.dataSource = self
        collection.delegate = self
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(UIImage(named: "sort"), for: .normal)
        button.addTarget(self, action: #selector(didTapSortButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPersons()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(ratingCollectionView)
        setupConstraints()
        setupNavigationBar()
    }
    
    private func setupConstraints() {
        [ratingCollectionView, sortButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            ratingCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            ratingCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ratingCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            ratingCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupNavigationBar() {
        let customBarButton = UIBarButtonItem(customView: sortButton)
        navigationItem.rightBarButtonItem = customBarButton
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .black
    }
    
    // MARK: - Data Loading
    
    private func loadPersons() {
        guard !isLoadingData else { return }
        isLoadingData = true
        ProgressHUD.show()
        
        statisticService.fetchNextPage { [weak self] result in
            guard let self = self else { return }
            self.isLoadingData = false
            ProgressHUD.dismiss()
            
            switch result {
            case .success(let newUsers):
                self.appendPersons(newUsers)
            case .failure(let error):
                self.showError(error)
            }
        }
    }
    
    private func appendPersons(_ newUsers: [Person]) {
        allPersons.append(contentsOf: newUsers)
        persons.append(contentsOf: newUsers)
        
        let newIndexPaths = (persons.count - newUsers.count..<persons.count).map { IndexPath(row: $0, section: 0) }
        ratingCollectionView.performBatchUpdates {
            ratingCollectionView.insertItems(at: newIndexPaths)
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Sorting
    
    @objc private func didTapSortButton() {
        presentSortOptions()
    }
    
    private func presentSortOptions() {
        let alertController = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        
        let sortByName = UIAlertAction(title: "По имени", style: .default) { _ in
            self.sortPersons(by: .name)
        }
        
        let sortByRating = UIAlertAction(title: "По рейтингу", style: .default) { _ in
            self.sortPersons(by: .rating)
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        [sortByName, sortByRating, cancel].forEach { alertController.addAction($0) }
        present(alertController, animated: true)
    }
    
    private func sortPersons(by criterion: SortCriterion) {
        switch criterion {
        case .name:
            persons.sort {
                $0.name.trimmingCharacters(in: .whitespacesAndNewlines) <
                    $1.name.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        case .rating:
            persons.sort { $0.nfts.count > $1.nfts.count }
        }
        ratingCollectionView.reloadData()
    }
}

// MARK: - Extensions

extension StatisticsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return persons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RatingCell.identifier, for: indexPath) as? RatingCell else {
            return UICollectionViewCell()
        }
        let person = persons[indexPath.row]
        cell.configure(indexPath: indexPath, person: person)
        return cell
    }
}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension StatisticsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = persons[indexPath.row]
        let profileVC = ProfileInfoView(person: person)
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

// MARK: - Supporting Types

enum SortCriterion {
    case name
    case rating
}
