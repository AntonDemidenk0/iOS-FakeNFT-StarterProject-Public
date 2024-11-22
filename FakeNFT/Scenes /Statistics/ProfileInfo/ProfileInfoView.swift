import UIKit
import Kingfisher

final class ProfileInfoView: UIViewController {
    
    // MARK: - Properties
    
    private var person: Person?
    
    // MARK: - UI Elements
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private lazy var descriptionText: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13, weight: .light)
        return label
    }()
    
    private lazy var webButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitle("Перейти на сайт пользователя", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
        button.addTarget(self, action: #selector(webButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nftCollection: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NFTsTableViewCell.self, forCellReuseIdentifier: "NFTsTableViewCell")
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
    
    // MARK: - Initializer
    
    init(person: Person?) {
        self.person = person
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) must be implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configure()
    }
    
    // MARK: - Configuration
    
    private func configure() {
        guard let person = self.person else { return }
        
        if person.avatar.hasPrefix("https://cloudflare-ipfs.com/ipfs") || person.avatar.hasPrefix("https://photo.bank") {
            avatarImage.image = UIImage(named: "userpick")
        } else {
            if let url = URL(string: person.avatar) {
                avatarImage.kf.setImage(with: url)
            }
        }
        
        nameLabel.text = person.name
        descriptionText.text = person.description
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        stackView.addArrangedSubview(avatarImage)
        stackView.addArrangedSubview(nameLabel)
        
        [stackView, descriptionText, webButton, nftCollection].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        [stackView, avatarImage, nameLabel, descriptionText, webButton, nftCollection].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
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
    
    // MARK: - Action Methods
    
    @objc private func webButtonTapped() {
        guard let url = person?.website, !url.isEmpty else { return }
        let webVC = WebViewController(url: url)
        navigationController?.pushViewController(webVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ProfileInfoView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NFTsTableViewCell", for: indexPath) as? NFTsTableViewCell else {
            return UITableViewCell()
        }
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right")?.withTintColor(.black, renderingMode: .alwaysOriginal))
        cell.configure(nftCount: person?.nfts.count ?? 0)
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProfileInfoView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let person = person?.nfts else { return }
        let vc = ProfileNFTsCollectionView(nftIDs: person)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
