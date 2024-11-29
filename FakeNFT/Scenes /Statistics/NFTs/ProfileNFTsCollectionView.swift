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
        fetchProfileAndCartData()
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
    
    private func fetchProfileAndCartData() {
            let group = DispatchGroup()
            
            group.enter()
            fetchProfile {
                group.leave()
            }
            
            group.enter()
            fetchCart {
                group.leave()
            }
            
            group.notify(queue: .main) {
                self.nftCollection.reloadData()
            }
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
    
    private func fetchCart(completion: @escaping () -> Void) {
            service.fetchCart { [weak self] result in
                switch result {
                case .success(let cartData):
                    self?.cart = cartData
                case .failure(let error):
                    print("Error fetching cart: \(error)")
                }
                completion()
            }
        }
    
    // MARK: - UI Updates
    
    private func updateView() {
        emptyCollectionLabel.isHidden = !visibleNFT.isEmpty
        nftCollection.reloadData()
    }
    
    func updateLike(nft: Nft, completion: @escaping (Result<Bool, Error>) -> Void) {
        UIProgressHUD.show()
        
        guard let profile = profile else {
            UIProgressHUD.dismiss()
            return
        }
        
        let (isLiked, updatedLikes) = toggleLike(for: nft, in: profile)
        
        updateLikes(updatedLikes) { [weak self] result in
            self?.handleLikeUpdateResult(result, isLiked: isLiked, completion: completion)
        }
    }

    private func toggleLike(for nft: Nft, in profile: ProfileModel) -> (Bool, [String]) {
        var likes = profile.likes
        let id = nft.id
        let isLiked: Bool
        
        if likes.contains(id) {
            likes.removeAll { $0 == id }
            isLiked = false
        } else {
            likes.append(id)
            isLiked = true
        }
        
        return (isLiked, likes)
    }

    private func updateLikes(_ likes: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let profile = profile else {
            completion(.failure(NSError(domain: "Profile not found", code: -1, userInfo: nil)))
            return
        }
        
        service.updateLikes(newLikes: likes, profile: profile) { result in
            completion(result)
        }
    }

    private func handleLikeUpdateResult(_ result: Result<Void, Error>, isLiked: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.main.async {
            UIProgressHUD.dismiss()
            
            switch result {
            case .success:
                self.getProfile {
                    completion(.success(isLiked))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateCart(nft: Nft, completion: @escaping (Result<Bool, Error>) -> Void) {
        UIProgressHUD.show()
        
        guard let cart = cart else {
            UIProgressHUD.dismiss()
            completion(.failure(NSError(domain: "Cart not found", code: -1, userInfo: nil)))
            return
        }
        
        let (isAdded, updatedCartItems) = toggleCartItem(for: nft, in: cart)
        
        updateCartItems(updatedCartItems) { [weak self] result in
            self?.handleCartUpdateResult(result, isAdded: isAdded, completion: completion)
        }
    }

    private func toggleCartItem(for nft: Nft, in cart: Cart) -> (Bool, [String]) {
        var cartItems = cart.nfts
        let id = nft.id
        let isAdded: Bool
        
        if cartItems.contains(id) {
            cartItems.removeAll { $0 == id }
            isAdded = false
        } else {
            cartItems.append(id)
            isAdded = true
        }
        
        return (isAdded, cartItems)
    }

    private func updateCartItems(_ cartItems: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let cart = cart else {
            completion(.failure(NSError(domain: "Cart not found", code: -1, userInfo: nil)))
            return
        }
        
        service.updateCart(newCart: cartItems, cart: cart) { result in
            completion(result)
        }
    }

    private func handleCartUpdateResult(_ result: Result<Void, Error>, isAdded: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.main.async {
            UIProgressHUD.dismiss()
            
            switch result {
            case .success:
                self.getCart()
                completion(.success(isAdded))
            case .failure(let error):
                completion(.failure(error))
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
        
        let nft = visibleNFT[indexPath.row]
        
        if let profile = profile, let cart = cart {
            cell.delegate = self
            cell.configure(nft: nft, cart: cart, profile: profile)
        }
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
            UIProgressHUD.dismiss()
            switch result {
            case .success(let isAdded):
                cell.setAdded(isAdded: isAdded)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func didTapLikeButton(_ cell: ProfileNFTCollectionCell, nft: Nft) {
        updateLike(nft: nft) { result in
            UIProgressHUD.dismiss()
            switch result {
            case .success(let isLiked):
                cell.setLiked(isLiked: isLiked)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
