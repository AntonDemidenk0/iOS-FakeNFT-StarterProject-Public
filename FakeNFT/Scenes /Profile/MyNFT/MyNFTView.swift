//
//  MyNFTView.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 14.11.24..
//

import UIKit
import Kingfisher

final class MyNFTView: UIView {
    
    private var nftItems: [MyNFT] = [] {
        didSet {
            updateUI()
        }
    }
    
    private lazy var nftTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(NFTCell.self, forCellReuseIdentifier: NFTCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("noNFTs", comment: "")
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor(named: "YBlackColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(nftTableView)
        addSubview(placeholderLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            nftTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            nftTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nftTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    func updateUI() {
        placeholderLabel.isHidden = !nftItems.isEmpty
    }
    
    func updateNFTs(with nfts: [MyNFT]) {
        nftItems = nfts
        nftTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MyNFTView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nftItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NFTCell.reuseIdentifier, for: indexPath) as! NFTCell
        let nft = nftItems[indexPath.row]
        cell.configure(with: nft)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
