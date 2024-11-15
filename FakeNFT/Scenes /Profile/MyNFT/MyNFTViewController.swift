//
//  MyNFTViewController.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 14.11.24..
//
import UIKit

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
        print("Filter button tapped")
    }
}


