import UIKit
import ProgressHUD

final class CatalogViewController: UIViewController {
    
    // MARK: - Properties
    
    let servicesAssembly: ServicesAssembly
    private let tableView = UITableView()
    private let sortButton = UIButton()
    private var collections: [NFTCollection] = []
    private var filteredCollections: [NFTCollection] = []
    private var currentSortOption: SortOption = .none
    private let sortOptionManager = SortOptionManager()
    private var isLoading = false
    
    // MARK: - Initialization
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupSortButton()
        setupTableView()
        configureProgressHUD()
        currentSortOption = sortOptionManager.load()
        fetchCollections()
    }
    
    // MARK: - Setup Methods
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.bounces = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sortButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CatalogTableViewCell.self, forCellReuseIdentifier: CatalogTableViewCell.identifier)
    }
    
    private func setupSortButton() {
        view.addSubview(sortButton)
        sortButton.setImage(UIImage(named: "sort"), for: .normal)
        sortButton.tintColor = .label
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            sortButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sortButton.widthAnchor.constraint(equalToConstant: 29),
            sortButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func configureProgressHUD() {
        ProgressHUD.colorBackground = .systemBackground
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.animationType = .circleStrokeSpin
    }
    
    // MARK: - Data Fetching
    
    private func fetchCollections() {
        guard !isLoading else { return }
        isLoading = true
        
        ProgressHUD.show("Loading...")
        servicesAssembly.nftService.fetchCollections { [weak self] (result: Result<[NFTCollection], Error>) in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                self?.isLoading = false
                switch result {
                case .success(let collections):
                    self?.collections = collections
                    self?.filteredCollections = collections
                    self?.tableView.reloadData() // Полностью перезагружаем таблицу
                case .failure(let error):
                    self?.showNetworkErrorAlert(error: error)
                }
            }
        }
    }
    
    // MARK: - Sorting
    
    private func applySortOption(_ option: SortOption, reloadTable: Bool = false) {
        currentSortOption = option
        sortOptionManager.save(option)
        filteredCollections = collections
        
        switch option {
        case .none:
            break
        case .byName:
            filteredCollections.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .byCount:
            filteredCollections.sort { $0.nfts.count > $1.nfts.count }
        }
        
        print("Applying sort: \(option). Filtered collections count: \(filteredCollections.count)")
        
        if reloadTable {
            UIView.transition(
                with: tableView,
                duration: 0.3,
                options: [.transitionCrossDissolve],
                animations: { self.tableView.reloadData() }
            )
        }
    }
    
    private func showNetworkErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: NSLocalizedString("Network Error", comment: ""),
            message: NSLocalizedString("Unable to fetch collections. Please check your internet connection and try again.", comment: ""),
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(
            title: NSLocalizedString("Retry", comment: "Попробовать снова"),
            style: .default
        ) { [weak self] _ in
            self?.fetchCollections()
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Отмена"),
            style: .cancel
        )
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    
    private func showRetryAlert(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: NSLocalizedString("Error", comment: ""),
            message: NSLocalizedString("Failed to load the image. Would you like to try again?", comment: ""),
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: NSLocalizedString("Retry", comment: ""), style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Actions
    
    @objc
    private func sortButtonTapped() {
        let alertController = UIAlertController(
            title: NSLocalizedString("Sort.title", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let sortByNameAction = UIAlertAction(
            title: NSLocalizedString("Sort.byName", comment: "По названию"),
            style: .default
        ) { [weak self] _ in
            self?.applySortOption(.byName, reloadTable: true)
        }
        alertController.addAction(sortByNameAction)
        
        let sortByCountAction = UIAlertAction(
            title: NSLocalizedString("Sort.byCount", comment: "По количеству"),
            style: .default
        ) { [weak self] _ in
            self?.applySortOption(.byCount, reloadTable: true)
        }
        alertController.addAction(sortByCountAction)
        
        let closeAction = UIAlertAction(
            title: NSLocalizedString("Sort.close", comment: "Закрыть"),
            style: .cancel
        )
        alertController.addAction(closeAction)
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension CatalogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCollections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogTableViewCell.identifier, for: indexPath) as? CatalogTableViewCell else {
            return UITableViewCell()
        }
        
        let collection = filteredCollections[indexPath.row]
        let imageUrl = collection.cover
        cell.configure(with: collection.name, nftCount: collection.nfts.count)
                
        ImageLoader.shared.loadImage(from: imageUrl) { [weak tableView] result in
            DispatchQueue.main.async {
                guard let currentCell = tableView?.cellForRow(at: indexPath) as? CatalogTableViewCell else {
                    return
                }
                currentCell.updateImage(result)
                
                if case .failure = result {
                    self.showRetryAlert(for: indexPath)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCollection = filteredCollections[indexPath.row]
        let nftCollectionVC = NFTCollectionViewController(collection: selectedCollection)
        navigationController?.pushViewController(nftCollectionVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 179
    }
}
