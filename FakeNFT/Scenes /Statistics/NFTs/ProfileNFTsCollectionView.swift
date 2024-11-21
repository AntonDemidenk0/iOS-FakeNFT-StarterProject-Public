import UIKit
import ProgressHUD

final class ProfileNFTsCollectionView: UIViewController {
    
    // MARK: - Properties
    
    var nftsIDs: [String] = []
    private var visibleNFT: [NFTModel] = []
    private var profile: ProfileModel?
    
    private let service = ProfileNFTService.shared
    
    // MARK: - UI Components
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var nftCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.register(ProfileNFTCollectionCell.self, forCellWithReuseIdentifier: ProfileNFTCollectionCell.identifier)
        return collection
    }()
    
    private lazy var emptyCollectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.text = "У пользователя еще нет NFT"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initializer
    
    init(nftIDs: [String]) {
        self.nftsIDs = nftIDs
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) must be implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchNFTs()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        title = "Коллекция NFT"
        view.backgroundColor = .systemBackground
        [nftCollection, emptyCollectionLabel].forEach(view.addSubview)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nftCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            nftCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nftCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyCollectionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyCollectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Data Fetching
    
    private func fetchNFTs() {
        ProgressHUD.show()
        service.nftsIDs = nftsIDs
        service.getNFT { [weak self] in
            guard let self = self else { return }
            self.visibleNFT = self.service.visibleNFT
            self.updateView()
            ProgressHUD.dismiss()
        }
    }
    
    private func fetchProfile(completion: @escaping () -> Void) {
        service.getProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                completion()
            case .failure(let error):
                print("Error fetching profile: \(error)")
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateView() {
        emptyCollectionLabel.isHidden = !visibleNFT.isEmpty
        nftCollection.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileNFTsCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleNFT.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileNFTCollectionCell.identifier, for: indexPath) as? ProfileNFTCollectionCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: visibleNFT[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileNFTsCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 52) / 3
        return CGSize(width: width, height: 192)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)
    }
}
