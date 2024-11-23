
import UIKit
import ProgressHUD

protocol NFTCollectionViewCellDelegate: AnyObject {
    func nftCollectionViewCellDidToggleCart(_ cell: NFTCollectionViewCell)
    func nftCollectionViewCellDidToggleFavorite(_ cell: NFTCollectionViewCell)
}

final class NFTCollectionViewController: UIViewController, ErrorView {
    
    // MARK: - Properties
    
    private let collection: NFTCollection
    private let servicesAssembly: ServicesAssembly
    private var nfts: [Nft] = []
    private var images: [String: UIImage] = [:]
    private var order: Order?
    private var profile: Profile?

    
    // MARK: - UI Elements
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var nftCollectionViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .left
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let authorLabel = UILabel()
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.textAlignment = .left
        authorLabel.textColor = .label
        authorLabel.numberOfLines = 1
        authorLabel.isUserInteractionEnabled = true
        return authorLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 3
        descriptionLabel.lineBreakMode = .byTruncatingTail
        return descriptionLabel
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, authorLabel, descriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var nftCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16 + tabBarHeight, right: 16)
        layout.itemSize = calculateItemSize()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(NFTCollectionViewCell.self, forCellWithReuseIdentifier: NFTCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    // MARK: - Initialization
    
    init(collection: NFTCollection, servicesAssembly: ServicesAssembly) {
        self.collection = collection
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeNavigationBar()
        setupUI()
        configureView()
        configureCover()
        fetchNFTs()
        fetchOrder()
        fetchProfile()
        setupCustomBackButton()
    }
    
    // MARK: - Setup Methods
    
    private func customizeNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .label
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupCustomBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(customBackButtonTapped)
        )
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
            
    private func calculateItemSize() -> CGSize {
        let numberOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = 16
        let totalSpacing = (2 * 16) + ((numberOfItemsPerRow - 1) * spacing)
        let collectionViewWidth = view.bounds.width
        let itemWidth = (collectionViewWidth - totalSpacing) / numberOfItemsPerRow
        let itemHeight = itemWidth * 1.78

        return CGSize(width: floor(itemWidth), height: floor(itemHeight))
    }

    private var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.height ?? 49
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        addSubviews()
        addConstraints()
        addTapGestureToAuthorLabel()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(coverImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(nftCollectionView)
    }
    
    private func addConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: view.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 310)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            nftCollectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            nftCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        nftCollectionViewHeightConstraint = nftCollectionView.heightAnchor.constraint(equalToConstant: 0)
        nftCollectionViewHeightConstraint?.isActive = true
    }
    
    private func addTapGestureToAuthorLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(authorLabelTapped))
        authorLabel.addGestureRecognizer(tapGesture)
    }
    
    private func initializePlaceholderNFTs(with nftIDs: [String]) {
        nfts = nftIDs.map { nftID in
            Nft(id: nftID, name: "Loading...", images: [], rating: 0, description: "", price: 0, author: "")
        }
    }
    
    private func configureView() {
        titleLabel.text = collection.name.capitalized
        
        let attributedText = NSMutableAttributedString(
            string: "Автор коллекции: ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                .foregroundColor: UIColor.label
            ]
        )
        attributedText.append(NSAttributedString(
            string: collection.author,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                .foregroundColor: UIColor.systemBlue,
            ]
        ))
        
        authorLabel.attributedText = attributedText
        
        descriptionLabel.text = collection.description
    }
    
    // MARK: - Data Loading
    
    private func configureCover() {
        ImageLoader.shared.loadImage(from: collection.cover) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self?.coverImageView.image = image
                case .failure:
                    self?.coverImageView.image = UIImage(named: "placeholder")
                }
            }
        }
    }
    
    private func fetchNFTs() {
        let uniqueNftIDs = Array(Set(collection.nfts))
        
        initializePlaceholderNFTs(with: uniqueNftIDs)
        nftCollectionView.reloadData()
        updateCollectionViewHeight()
        
        servicesAssembly.nftService.fetchNFTs(nftIDs: uniqueNftIDs) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let nfts):
                    self?.nfts = nfts
                    self?.loadImages(for: nfts) {
                        self?.nftCollectionView.reloadData()
                        self?.updateCollectionViewHeight()
                    }
                case .failure:
                    let errorModel = ErrorModel(
                        message: NSLocalizedString(
                            "Unable to load NFTs. Please check your internet connection and try again.",
                            comment: "Не удалось загрузить NFT. Проверьте подключение к интернету и повторите попытку."
                        ),
                        actionText: NSLocalizedString("Retry", comment: "Повторить"),
                        action: { [weak self] in
                            self?.fetchNFTs()
                            self?.configureCover()
                        }
                    )
                    self?.showError(errorModel)
                }
            }
        }
    }

    private func loadImages(for nfts: [Nft], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        for (index, nft) in nfts.enumerated() {
            guard let imageUrl = nft.imageUrls.first?.absoluteString else {
                continue
            }
            
            dispatchGroup.enter()
            
            ImageLoader.shared.loadImage(from: imageUrl) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else {
                        dispatchGroup.leave()
                        return
                    }
                    switch result {
                    case .success(let image):
                        self.images[nft.id] = image
                    case .failure:
                        self.images[nft.id] = UIImage(named: "placeholder")
                        if index == 0 {
                            let errorModel = ErrorModel(
                                message: NSLocalizedString(
                                    "Failed to load some images. Please check your connection.",
                                    comment: "Не удалось загрузить некоторые изображения. Проверьте подключение к интернету."
                                ),
                                actionText: NSLocalizedString("Retry", comment: "Повторить"),
                                action: { [weak self] in
                                    self?.fetchNFTs()
                                }
                            )
                            self.showError(errorModel)
                        }
                    }
                    
                    if let cell = self.nftCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? NFTCollectionViewCell {
                        cell.configure(with: nft, image: self.images[nft.id])
                    }
                    
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    private func updateCollectionViewHeight() {
        guard let layout = nftCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let itemHeight = layout.itemSize.height
        let itemSpacing = layout.minimumLineSpacing
        let itemsPerRow: CGFloat = 3
        let numberOfItems = CGFloat(nfts.count)
        let numberOfRows = ceil(numberOfItems / itemsPerRow)
        let sectionInset = layout.sectionInset
        
        let collectionViewHeight = (numberOfRows * itemHeight) + ((numberOfRows - 1) * itemSpacing) + sectionInset.top + sectionInset.bottom
        
        nftCollectionViewHeightConstraint?.constant = collectionViewHeight
        view.layoutIfNeeded()
    }
    
    private func fetchOrder() {
        servicesAssembly.nftService.fetchOrder { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let order):
                    self?.order = order
                    self?.nftCollectionView.reloadData()
                case .failure(let error):
                    print("Failed to fetch order: \(error)")
                    self?.showError(ErrorModel(
                        message: NSLocalizedString("Failed to load cart. Please try again.", comment: ""),
                        actionText: NSLocalizedString("Retry", comment: ""),
                        action: { [weak self] in
                            self?.fetchOrder()
                        }
                    ))
                }
            }
        }
    }
    
    private func fetchProfile() {
        servicesAssembly.nftService.fetchProfile { [weak self] (result: Result<Profile, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.profile = profile
                    self?.nftCollectionView.reloadData()
                case .failure(let error):
                    print("Failed to fetch profile: \(error)")
                }
            }
        }
    }
    
    @objc
    private func customBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func authorLabelTapped() {
        guard let nftAuthorURLString = nfts.first?.author.trimmingCharacters(in: .whitespacesAndNewlines),
              !nftAuthorURLString.isEmpty,
              let websiteURL = URL(string: nftAuthorURLString) else {
            showError(ErrorModel(
                message: "Author's website is not available.",
                actionText: "OK",
                action: {}
            ))
            return
        }
        
        print("NFT Author URL: \(nftAuthorURLString)")
        
        let webViewController = AuthorWebViewController(url: websiteURL)
        let navigationController = UINavigationController(rootViewController: webViewController)
        self.present(navigationController, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension NFTCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of items in section: \(nfts.count)")
        return nfts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NFTCollectionViewCell.identifier,
            for: indexPath
        ) as? NFTCollectionViewCell else {
            fatalError("Could not dequeue NFTCollectionViewCell")
        }

        let nft = nfts[indexPath.item]
        let image = images[nft.id]
        cell.configure(with: nft, image: image)

        let isInCart = order?.nfts.contains(nft.id) ?? false
        cell.setCartState(isInCart)
        
        let isFavorite = profile?.likes.contains(nft.id) ?? false
        cell.setFavoriteState(isFavorite)

        cell.delegate = self
        return cell
    }
}

extension NFTCollectionViewController {
    
    private func toggleCart(for nft: Nft) {
        guard var order = self.order else { return }
        
        if let index = order.nfts.firstIndex(of: nft.id) {
            order.nfts.remove(at: index)
        } else {
            order.nfts.append(nft.id)
        }
        print("Updated order: \(order)")
        servicesAssembly.nftService.updateOrder(order) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedOrder):
                    self?.order = updatedOrder
                    print("Order successfully updated")
                    if let index = self?.nfts.firstIndex(where: { $0.id == nft.id }) {
                        self?.nftCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                case .failure(let error):
                    print("Failed to update order: \(error)")
                }
            }
        }
    }
    
    private func toggleFavorite(for nft: Nft) {
        guard var profile = self.profile else {
            print("Ошибка: профиль отсутствует.")
            return
        }
        
        print("Лайки до обновления: \(profile.likes)")
        
        if let index = profile.likes.firstIndex(of: nft.id) {
            profile.likes.remove(at: index)
        } else {
            profile.likes.append(nft.id)
        }
        
        print("Лайки после обновления: \(profile.likes)")
        
        servicesAssembly.nftService.updateProfile(profile) { [weak self] result in
            print("updateProfile вызван")
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedProfile):
                    self?.profile = updatedProfile
                    print("Профиль успешно обновлен: \(updatedProfile.likes)")
                    if let index = self?.nfts.firstIndex(where: { $0.id == nft.id }) {
                        self?.nftCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                case .failure(let error):
                    print("Ошибка при обновлении профиля: \(error)")
                }
            }
        }
    }
}

extension NFTCollectionViewController: NFTCollectionViewCellDelegate {
    
    func nftCollectionViewCellDidToggleCart(_ cell: NFTCollectionViewCell) {
        guard let indexPath = nftCollectionView.indexPath(for: cell) else { return }
        let nft = nfts[indexPath.item]
        toggleCart(for: nft)
    }
    
    func nftCollectionViewCellDidToggleFavorite(_ cell: NFTCollectionViewCell) {
        guard let indexPath = nftCollectionView.indexPath(for: cell) else { return }
        let nft = nfts[indexPath.item]
        toggleFavorite(for: nft)
    }
}


