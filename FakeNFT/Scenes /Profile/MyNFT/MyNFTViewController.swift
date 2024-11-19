//
//  MyNFTViewController.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 14.11.24..
//
import UIKit

enum SortType {
        case price
        case rating
        case name
    }

final class MyNFTViewController: UIViewController {
    
    var nfts: [MyNFT] = []
    
    override func loadView() {
        self.view = MyNFTView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        
        if let myNFTView = view as? MyNFTView {
            myNFTView.updateNFTs(with: nfts)
        }
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
        let alert = UIAlertController(title: NSLocalizedString("Sort by", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("by Price", comment: ""), style: .default, handler: { _ in
            self.sortNFTs(by: .price)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("by Rating", comment: ""), style: .default, handler: { _ in
            self.sortNFTs(by: .rating)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("by Name", comment: ""), style: .default, handler: { _ in
            self.sortNFTs(by: .name)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func sortNFTs(by type: SortType) {
            switch type {
            case .price:
                nfts.sort { $0.price < $1.price }
            case .rating:
                nfts.sort { $0.rating > $1.rating }
            case .name:
                nfts.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            }
            
            if let myNFTView = view as? MyNFTView {
                myNFTView.updateNFTs(with: nfts)
            }
        }
    }



