import UIKit

final class CatalogViewController: UIViewController {

    let servicesAssembly: ServicesAssembly
//    let testNftButton = UIButton()
    
    private let tableView = UITableView()
    private let sortButton = UIButton()
    
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
        
//        view.addSubview(testNftButton)
//        testNftButton.constraintCenters(to: view)
//        testNftButton.setTitle(Constants.openNftTitle, for: .normal)
//        testNftButton.addTarget(self, action: #selector(showNft), for: .touchUpInside)
//        testNftButton.setTitleColor(.systemBlue, for: .normal)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
        ) { _ in
            print("Sort by name selected")
        }
        alertController.addAction(sortByNameAction)
        
        let sortByCountAction = UIAlertAction(
            title: NSLocalizedString("Sort.byCount", comment: "По количеству"),
            style: .default
        ) { _ in
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


    @objc
    func showNft() {
        let assembly = NftDetailAssembly(servicesAssembler: servicesAssembly)
        let nftInput = NftDetailInput(id: Constants.testNftId)
        let nftViewController = assembly.build(with: nftInput)
        present(nftViewController, animated: true)
    }
}

private enum Constants {
    static let openNftTitle = NSLocalizedString("Catalog.openNft", comment: "")
    static let testNftId = "7773e33c-ec15-4230-a102-92426a3a6d5a"
}

extension CatalogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogTableViewCell.identifier, for: indexPath) as? CatalogTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: "Collection \(indexPath.row + 1)", image: UIImage(named: "placeholder"))
        return cell
    }
}
