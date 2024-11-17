//
//  NFTCollectionViewController.swift
//  FakeNFT
//
//  Created by GiyaDev on 15.11.2024.
//

import UIKit

final class NFTCollectionViewController: UIViewController {
    
    // MARK: - Properties
    
    private let collection: NFTCollection
    private let servicesAssembly: ServicesAssembly
    private var nfts: [Nft] = []
    private var images: [String: UIImage] = [:]
    
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
        label.textColor = .label
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let authorLabel = UILabel()
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.textAlignment = .left
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 1
        authorLabel.textColor = .label
        return authorLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 3
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.textColor = .label
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
        layout.itemSize = CGSize(width: 108, height: 192)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(NFTCollectionViewCell.self, forCellWithReuseIdentifier: NFTCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
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
        initializePlaceholderNFTs()
        setupUI()
        configureView()
        configureCover()
        fetchNFTs()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(coverImageView)
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: view.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 310)
        ])
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(nftCollectionView)
        NSLayoutConstraint.activate([
            nftCollectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            nftCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nftCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nftCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func initializePlaceholderNFTs() {
        nfts = collection.nfts.map { nftID in
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
                .foregroundColor: UIColor.systemBlue
            ]
        ))
        
        authorLabel.attributedText = attributedText
        
        descriptionLabel.text = collection.description
    }
    
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
        servicesAssembly.nftService.fetchNFTs(nftIDs: collection.nfts) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let nfts):
                    self?.nfts = nfts
                    self?.loadImages(for: nfts)
                    self?.nftCollectionView.reloadData()
                case .failure(let error):
                    print("Failed to load NFTs: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadImages(for nfts: [Nft]) {
        for (index, nft) in nfts.enumerated() {
            guard let imageUrl = nft.imageUrls.first?.absoluteString else { continue }
            
            ImageLoader.shared.loadImage(from: imageUrl) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let image):
                        self.images[nft.id] = image
                    case .failure:
                        self.images[nft.id] = UIImage(named: "placeholder")
                    }
                    if let cell = self.nftCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? NFTCollectionViewCell {
                        cell.configure(with: nft, image: self.images[nft.id])
                    }
                }
            }
        }
    }
}

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
        return cell
    }
}
