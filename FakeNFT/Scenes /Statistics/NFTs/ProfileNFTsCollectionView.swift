import UIKit
import ProgressHUD

final class ProfileNFTsCollectionView: UIViewController {
    
    // MARK: - Properties
    
    private var nftsIDs: [String] = []
    private var visibleNFT: [Nft] = []
    private var profile: ProfileModel?
    
    private let service = ProfileNFTService.shared
    private var cart: Cart?
    private var nft: Nft?
    
    // MARK: - UI Components
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var nftCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.dataSource = self
        collection.delegate = self
        collection.register(ProfileNFTCollectionCell.self, forCellWithReuseIdentifier: ProfileNFTCollectionCell.identifier)
        return collection
    }()
    
    private lazy var emptyCollectionLabel: UILabel = {
        let label = UILabel()
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
        getCart()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        title = "Коллекция NFT"
        view.backgroundColor = .systemBackground
        [nftCollection, emptyCollectionLabel].forEach(view.addSubview)
        setupConstraints()
    }
    
    private func setupConstraints() {
        [nftCollection, emptyCollectionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
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
        service.fetchNFTs(for: nftsIDs) { [weak self] result in
            ProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let models):
                self.visibleNFT = models
                self.updateView()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchProfile(completion: @escaping () -> Void) {
        service.fetchProfile { [weak self] result in
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
    
    func updateLike(nft: Nft, completion: @escaping (Result<Bool, Error>) -> Void) {
        UIProgressHUD.show()
        service.fetchProfile { result in
            switch result {
            case .success(let model):
                var likes = model.likes
                let id = nft.id
                let isLiked: Bool
                
                if likes.contains(id) {
                    likes.removeAll { $0 == id }
                    isLiked = false
                } else {
                    likes.append(id)
                    isLiked = true
                }
                
                self.service.updateLikes(newLikes: likes, profile: model) { [weak self] result in
                    DispatchQueue.main.async {
                        UIProgressHUD.dismiss()
                        switch result {
                        case .success:
                            self?.getProfile() {
                                completion(.success(isLiked))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    UIProgressHUD.dismiss()
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateCart(nft: Nft, completion: @escaping (Result<Bool, Error>) -> Void) {
        UIProgressHUD.show()
        
        service.fetchCart { result in
            switch result {
            case .success(let model):
                var cart = model.nfts
                let id = nft.id
                let isAdded: Bool
                
                if cart.contains(id) {
                    cart.removeAll { $0 == id }
                    isAdded = false
                } else {
                    cart.append(id)
                    isAdded = true
                }
                
                self.service.updateCart(newCart: cart, cart: model) { [weak self] result in
                    DispatchQueue.main.async {
                        UIProgressHUD.dismiss()
                        switch result {
                        case .success:
                            self?.getCart()
                            completion(.success(isAdded))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    UIProgressHUD.dismiss()
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getProfile(completion: @escaping () -> Void) {
        service.fetchProfile { result in
            switch result {
            case .success(let object):
                self.profile = object
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getCart() {
        service.fetchCart { result in
            switch result {
            case .success(let order):
                self.cart = order
            case .failure(let error):
                print(error)
            }
        }
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
        cell.delegate = self
        cell.configure(with: visibleNFT[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileNFTsCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.bounds.width - 52) / 3)
        return CGSize(width: width, height: 192)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)
    }
}

extension ProfileNFTsCollectionView: ProfileNFTCellDelegate {
    
    func didTapAddToCartButton(_ cell: ProfileNFTCollectionCell, nft: Nft) {
        updateCart(nft: nft) { result in
            switch result {
            case .success(let isAdded):
                cell.setAdded(isAdded: isAdded)
                UIProgressHUD.dismiss()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func didTapLikeButton(_ cell: ProfileNFTCollectionCell, nft: Nft) {
        updateLike(nft: nft) { result in
            switch result {
            case .success(let isLiked):
                cell.setLiked(isLiked: isLiked)
                UIProgressHUD.dismiss()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
