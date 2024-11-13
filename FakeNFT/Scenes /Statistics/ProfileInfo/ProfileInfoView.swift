import UIKit

final class ProfileInfoView: UIViewController {
    
    private var object: Person?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    private let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 28
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let descriptionText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var webButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitle("Перейти на сайт пользователя", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(webButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nftCollection: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NFTsTableViewCell.self, forCellReuseIdentifier: "NFTsTableViewCell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    init(object: Person?) {
        self.object = object
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configure()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        stackView.addArrangedSubview(avatarImage)
        stackView.addArrangedSubview(nameLabel)
        [stackView, descriptionText, webButton, nftCollection].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            
            descriptionText.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            descriptionText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            webButton.topAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 28),
            webButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            webButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            webButton.heightAnchor.constraint(equalToConstant: 40),
            
            nftCollection.topAnchor.constraint(equalTo: webButton.bottomAnchor, constant: 40),
            nftCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nftCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nftCollection.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configure() {
        avatarImage.image = UIImage(named: object?.image ?? "")
        nameLabel.text = object?.name
        descriptionText.text = object?.description
    }
    
    @objc private func webButtonTapped() {
        guard let url = object?.webSite, !url.isEmpty else { return }
        let webVC = WebViewController(url: url)
        navigationController?.pushViewController(webVC, animated: true)
    }
}

extension ProfileInfoView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NFTsTableViewCell", for: indexPath) as? NFTsTableViewCell else {
            return UITableViewCell()
        }
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right")?.withTintColor(.black, renderingMode: .alwaysOriginal))
        cell.configure(with: object?.nftCount ?? 0)
        return cell
    }
}

extension ProfileInfoView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nfts = object?.nft else { return }
        let collectionVC = ProfileNFTsCollectionView(nft: nfts)
        collectionVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(collectionVC, animated: true)
    }
}
