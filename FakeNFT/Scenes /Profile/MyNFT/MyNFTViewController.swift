//
//  MyNFTViewController.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 14.11.24..
//
import UIKit

enum SortType: String {
    case price
    case rating
    case name
}

final class MyNFTViewController: UIViewController {

    var nfts: [MyNFT] = []
    private let sortTypeKey = "selectedSortType"

    override func loadView() {
        self.view = MyNFTView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupNavigationBar()
        
        let savedSortType = getSavedSortType()
        sortNFTs(by: savedSortType)
        
        updateNFTView()
    }

    private func setupNavigationBar() {
        title = NSLocalizedString("MyNFT", comment: "")
        navigationController?.navigationBar.tintColor = UIColor(named: "YBlackColor")

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "sort_button"),
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func filterButtonTapped() {
        let alert = UIAlertController(
            title: NSLocalizedString("Sort by", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("by Price", comment: ""),
            style: .default,
            handler: { [weak self] _ in
                self?.sortNFTs(by: .price)
            }
        ))

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("by Rating", comment: ""),
            style: .default,
            handler: { [weak self] _ in
                self?.sortNFTs(by: .rating)
            }
        ))

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("by Name", comment: ""),
            style: .default,
            handler: { [weak self] _ in
                self?.sortNFTs(by: .name)
            }
        ))

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Close", comment: ""),
            style: .cancel,
            handler: nil
        ))

        present(alert, animated: true, completion: nil)
    }

    func sortNFTs(by type: SortType) {
        UserDefaults.standard.set(type.rawValue, forKey: sortTypeKey)

        switch type {
        case .price:
            nfts.sort { $0.price < $1.price }
        case .rating:
            nfts.sort { $0.rating > $1.rating }
        case .name:
            nfts.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }

        updateNFTView()
    }

    private func getSavedSortType() -> SortType {
        guard let rawValue = UserDefaults.standard.string(forKey: sortTypeKey),
              let savedType = SortType(rawValue: rawValue) else {
            return .rating
        }
        return savedType
    }

    private func updateNFTView() {
        (view as? MyNFTView)?.updateNFTs(with: nfts)
    }
}
