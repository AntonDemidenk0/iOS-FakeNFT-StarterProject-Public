//
//  FavoritesNftViewController.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 22.11.24..
//
import UIKit

final class FavoritesNftViewController: UIViewController {
    
    var favoriteNfts: [MyNFT] = []

    override func loadView() {
        self.view = FavoritesNftView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupNavigationBar()
        updateNFTView()
    }

    private func setupNavigationBar() {
        title = NSLocalizedString("Favorites", comment: "")
        navigationController?.navigationBar.tintColor = UIColor(named: "YBlackColor")

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func updateNFTView() {
        (view as? FavoritesNftView)?.updateNFTs(with: favoriteNfts)
    }
}
