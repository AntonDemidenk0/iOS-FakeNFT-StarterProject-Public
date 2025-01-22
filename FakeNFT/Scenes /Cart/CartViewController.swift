//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 11.11.2024.
//

import UIKit
import ProgressHUD

final class CartViewController: UIViewController, LoadingView, ErrorView {

    private let cartService: CartService
    private var cartItems: [CartItem] = []
    internal lazy var activityIndicator = UIActivityIndicatorView()
    
    private let orderId: String
    private var isLoadingCart = false
    
    private lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = false
        navBar.backgroundColor = .background
        
        let navItem = UINavigationItem()
        let sortBarButton = UIBarButtonItem(customView: sortButton)
        navItem.rightBarButtonItem = sortBarButton
        
        navBar.setItems([navItem], animated: false)
        return navBar
    }()

    private lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .light), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(sortItems), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        button.isEnabled = true
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Корзина пуста"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private lazy var paymentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0
        view.backgroundColor = UIColor.segmentInactive
        return view
    }()
    
    private lazy var itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .textGreen
        return label
    }()
    
    private lazy var checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Оплатить", for: .normal)
        button.backgroundColor = UIColor.payButton
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(goToPayment), for: .touchUpInside)
        return button
    }()

    init(cartService: CartService, orderId: String) {
        self.cartService = cartService
        self.orderId = orderId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        loadCartItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCartItems()
    }

    private func setupUI() {
        view.addSubview(navigationBar)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(paymentView)
        paymentView.addSubview(itemCountLabel)
        paymentView.addSubview(totalPriceLabel)
        paymentView.addSubview(checkoutButton)
        
        sortButton.isEnabled = false

        setupConstraints()
    }

    private func setupConstraints() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        paymentView.translatesAutoresizingMaskIntoConstraints = false
        itemCountLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 42),
            
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: paymentView.topAnchor, constant: -16),
            
            paymentView.heightAnchor.constraint(equalToConstant: 76),
            paymentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paymentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            paymentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            itemCountLabel.topAnchor.constraint(equalTo: paymentView.topAnchor, constant: 16),
            itemCountLabel.leadingAnchor.constraint(equalTo: paymentView.leadingAnchor, constant: 16),
            totalPriceLabel.topAnchor.constraint(equalTo: itemCountLabel.bottomAnchor, constant: 2),
            totalPriceLabel.leadingAnchor.constraint(equalTo: paymentView.leadingAnchor, constant: 16),
            
            checkoutButton.centerYAnchor.constraint(equalTo: paymentView.centerYAnchor),
            checkoutButton.trailingAnchor.constraint(equalTo: paymentView.trailingAnchor, constant: -16),
            checkoutButton.widthAnchor.constraint(equalToConstant: 240),
            checkoutButton.heightAnchor.constraint(equalToConstant: 44),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func sortItems() {
        let currentSortType = SortType.load()
        
        let alertController = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        
        let priceAction = UIAlertAction(
            title: "По цене",
            style: .default,
            handler: { [weak self] _ in
                self?.performSort(by: .price)
            }
        )
        if currentSortType == .price {
            priceAction.setValue(UIImage(systemName: "checkmark"), forKey: "image")
        }
        alertController.addAction(priceAction)
        
        let ratingAction = UIAlertAction(
            title: "По рейтингу",
            style: .default,
            handler: { [weak self] _ in
                self?.performSort(by: .rating)
            }
        )
        if currentSortType == .rating {
            ratingAction.setValue(UIImage(systemName: "checkmark"), forKey: "image")
        }
        alertController.addAction(ratingAction)
        
        let nameAction = UIAlertAction(
            title: "По названию",
            style: .default,
            handler: { [weak self] _ in
                self?.performSort(by: .name)
            }
        )
        if currentSortType == .name {
            nameAction.setValue(UIImage(systemName: "checkmark"), forKey: "image")
        }
        alertController.addAction(nameAction)
        
        alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }

    private enum SortType: String {
        case price, rating, name

        func save() {
            UserDefaults.standard.set(self.rawValue, forKey: UserDefaultsKeys.sortType)
        }

        static func load() -> SortType {
            let rawValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.sortType)
            return SortType(rawValue: rawValue ?? "") ?? .name
        }
    }

    private func performSort(by type: SortType) {
        switch type {
        case .price:
            cartItems.sort { $0.price < $1.price }
        case .rating:
            cartItems.sort { $0.rating > $1.rating }
        case .name:
            cartItems.sort { $0.name < $1.name }
        }
        
        type.save()
        
        tableView.reloadData()
    }
    
    @objc private func goToPayment() {
        print("💳 Переход на экран оплаты")
        
        let networkClient = DefaultNetworkClient()
        let paymentService = PaymentServiceImpl(networkClient: networkClient)
        
        let paymentViewController = PaymentViewController(
            paymentService: paymentService,
            orderId: orderId,
            onSuccessPayment: { [weak self] in
                self?.navigateToCatalog()
            }
        )
        
        paymentViewController.modalPresentationStyle = .fullScreen
        present(paymentViewController, animated: true)
    }

    private func navigateToCatalog() {
        guard let tabBarController = self.tabBarController else { return }
        tabBarController.selectedIndex = 0 // Переход на вкладку каталога
    }
    
    private func loadCartItems() {
        guard !isLoadingCart else { return }
        isLoadingCart = true
        
        print("🔄 Загрузка всех товаров...")
        
        ProgressHUD.show()
        
        sortButton.isEnabled = false
        emptyStateLabel.isHidden = false
        paymentView.isHidden = true

        cartService.loadCartItems(orderId: orderId) { [weak self] (result: Result<[CartItem], Error>) in
            guard let self = self else { return }
            self.isLoadingCart = false
            ProgressHUD.dismiss()
            
            switch result {
            case .success(let items):
                print("✅ Успешно загружено \(items.count) товаров")
                self.cartItems = items
                
                let savedSortType = SortType.load()
                self.performSort(by: savedSortType)
                self.updateView()
            case .failure(let error):
                print("❌ Ошибка загрузки товаров: \(error)")
                let errorModel = ErrorModel(
                    message: "Ошибка загрузки корзины",
                    actionText: "Повторить",
                    action: { [weak self] in self?.loadCartItems() }
                )
                self.showError(errorModel)
            }
            
            self.sortButton.isEnabled = true
            self.paymentView.isHidden = false
            self.updateEmptyState()
        }
    }

    private func deleteCartItem(at indexPath: IndexPath) {
        guard cartItems.indices.contains(indexPath.row) else {
            print("Ошибка: Попытка удалить несуществующий элемент по индексу \(indexPath.row)")
            return
        }

        let item = cartItems[indexPath.row]
        
        // Показываем индикатор прогресса
        ProgressHUD.show()
        
        cartService.deleteCartItem(orderId: orderId, itemId: item.id) { [weak self] result in
            guard let self = self else { return }
            
            // Скрываем индикатор прогресса
            ProgressHUD.dismiss()
            
            switch result {
            case .success:
                // Удаляем товар из массива
                self.cartItems.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    // Обновляем таблицу
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.updateEmptyState()
                    self.updatePaymentInfo()
                }
            case .failure(let error):
                print("❌ Ошибка удаления товара: \(error)")
                // Показываем сообщение об ошибке
                let errorModel = ErrorModel(
                    message: "Не удалось удалить товар",
                    actionText: "Повторить",
                    action: { [weak self] in
                        self?.deleteCartItem(at: indexPath)
                    }
                )
                self.showError(errorModel)
            }
        }
    }

    private func updateView() {
        tableView.reloadData()
        updateEmptyState()
        updatePaymentInfo()
    }

    private func updateEmptyState() {
        let isEmpty = cartItems.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        paymentView.isHidden = isEmpty
    }

    private func updatePaymentInfo() {
        let totalPrice = cartItems.reduce(0) { $0 + $1.price }
        totalPriceLabel.text = String(format: "%.2f ETH", totalPrice)
        
        let itemCount = cartItems.count
        itemCountLabel.text = "\(itemCount) NFT"
        
        checkoutButton.isHidden = cartItems.isEmpty
    }
    
    private func removeItem(at indexPath: IndexPath) {
        guard cartItems.indices.contains(indexPath.row) else {
            print("Ошибка: Невозможно удалить элемент, индекс \(indexPath.row) вне диапазона")
            return
        }
        showConfirmDelete(for: cartItems[indexPath.row], at: indexPath)
    }
    
    private func showConfirmDelete(for item: CartItem, at indexPath: IndexPath) {
        let imageUrlString = item.imageUrl ?? "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Ellsa/1.png"
        let confirmVC = ConfirmDeleteViewController(imageUrlString: imageUrlString)
        confirmVC.onDeleteConfirmed = { [weak self] in
            self?.deleteCartItem(at: indexPath)
        }
        present(confirmVC, animated: true, completion: nil)
    }
}

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseIdentifier, for: indexPath) as? CartItemCell else {
            return UITableViewCell()
        }
        let item = cartItems[indexPath.row]
        
        cell.configure(with: item, onDelete: { [weak self] in
            self?.removeItem(at: indexPath)
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

private enum UserDefaultsKeys {
    static let sortType = "CartSortType"
}
