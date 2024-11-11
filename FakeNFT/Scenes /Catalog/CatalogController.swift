import UIKit
import ProgressHUD


final class CatalogViewController: UIViewController {

    let servicesAssembly: ServicesAssembly

    private let tableView = UITableView()
    private let sortButton = UIButton()
    private var collections: [NFTCollection] = []
    private var filteredCollections: [NFTCollection] = []
    private var currentSortOption: SortOption = .none
    private let sortOptionManager = SortOptionManager()
    private var isLoading = false

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupSortButton()
        setupTableView()
        progressLoader()
        currentSortOption = sortOptionManager.load()
        fetchCollections()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
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
                    if self?.collections != collections {
                        print("Updating collections data")
                        self?.collections = collections
                        self?.filteredCollections = collections
                        self?.applySortOption(self?.currentSortOption ?? .none, reloadTable: true) // Применение сортировки и обновление
                    } else {
                        print("No changes in collections data.")
                    }
                case .failure(let error):
                    print("Failed to fetch collections:", error.localizedDescription)
                    ProgressHUD.showError("Failed to load data")
                }
            }
        }
    }
    
    private func progressLoader() {
        ProgressHUD.colorBackground = .systemBackground
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.animationType = .circleStrokeSpin
    }
    
    private func applySortOption(_ option: SortOption, reloadTable: Bool = false) {
        // Сохраняем текущую сортировку
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
        UIView.performWithoutAnimation {
            tableView.reloadData()
        }
    }

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
            print("Sort by name selected")
        }
        alertController.addAction(sortByNameAction)

        let sortByCountAction = UIAlertAction(
            title: NSLocalizedString("Sort.byCount", comment: "По количеству"),
            style: .default
        ) { [weak self] _ in
            self?.applySortOption(.byCount, reloadTable: true)
            print("Sort by count selected")
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

extension CatalogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCollections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogTableViewCell.identifier, for: indexPath) as? CatalogTableViewCell else {
            return UITableViewCell()
        }

        let collection = filteredCollections[indexPath.row]
        cell.configure(with: collection.name, nftCount: collection.nfts.count, imageUrl: collection.cover)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 179
    }
}
