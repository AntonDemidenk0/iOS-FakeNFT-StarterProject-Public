//
//  PaymentViewController.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 12.11.2024.
//

import UIKit
import ProgressHUD

final class PaymentViewController: UIViewController, LoadingView, ErrorView {
    internal lazy var activityIndicator = UIActivityIndicatorView()
    
    private let paymentService: PaymentService
    private var currencies: [Currency] = []
    private var selectedCurrencyId: String?
    private let orderId: String
    private let onSuccessPayment: (() -> Void)?
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выберите способ оплаты"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 7
        layout.minimumInteritemSpacing = 7
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PaymentCell.self, forCellWithReuseIdentifier: PaymentCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0
        view.backgroundColor = UIColor.segmentInactive
        return view
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Оплатить", for: .normal)
        button.backgroundColor = UIColor.payButton
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let agreementLabel: UILabel = {
        let label = UILabel()
        label.text = "Совершая покупку, вы соглашаетесь с условиями"
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let agreementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Пользовательское соглашение", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(showAgreement), for: .touchUpInside)
        return button
    }()
    
    init(paymentService: PaymentService, orderId: String, onSuccessPayment: (() -> Void)?) {
        self.paymentService = paymentService
        self.orderId = orderId
        self.onSuccessPayment = onSuccessPayment
        super.init(nibName: nil, bundle: nil)
        print("🎉 PaymentViewController инициализирован")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        loadCurrencies()
    }
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        bottomView.addSubview(agreementLabel)
        bottomView.addSubview(agreementButton)
        bottomView.addSubview(payButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        agreementLabel.translatesAutoresizingMaskIntoConstraints = false
        agreementButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 42),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 9),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -20),
            
            bottomView.heightAnchor.constraint(equalToConstant: 152),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            agreementLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            agreementLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            agreementLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -43),
            
            agreementButton.topAnchor.constraint(equalTo: agreementLabel.bottomAnchor),
            agreementButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            agreementButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -157),
            
            payButton.topAnchor.constraint(equalTo: agreementButton.bottomAnchor, constant: 16),
            payButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -20),
            payButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func loadCurrencies() {
        print("🟢 [PaymentViewController] Начинаем загрузку валют")
        ProgressHUD.show()
        
        paymentService.fetchCurrencies { [weak self] result in
            guard let self = self else {
                print("🛑 [PaymentViewController] Сильная ссылка утрачена, загрузка валют не удалась")
                return
            }
            
            ProgressHUD.dismiss()
            switch result {
            case .success(let currencies):
                self.currencies = currencies
                self.collectionView.reloadData()
                print("✅ [PaymentViewController] Успешно загрузили валюты: \(currencies.count) шт.")
                
            case .failure(let error):
                print("🛑 [PaymentViewController] Ошибка при загрузке валют: \(error.localizedDescription)")
                self.showError(
                    ErrorModel(
                        message: "Не удалось произвести оплату",
                        actionText: "Повторить",
                        action: { [weak self] in
                            self?.loadCurrencies()
                        },
                        secondaryActionText: "Отмена",
                        secondaryAction: { [weak self] in
                            self?.dismiss(animated: true, completion: nil)
                            
                        }
                    )
                )
            }
        }
    }

    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func payButtonTapped() {
        guard let currencyId = selectedCurrencyId else { return }
        
        ProgressHUD.show()
        paymentService.makePayment(orderId: orderId, currencyId: currencyId) { [weak self] result in
            ProgressHUD.dismiss()
            switch result {
            case .success:
                self?.showSuccess()
            case .failure:
                self?.showError(ErrorModel(message: "Не удалось произвести оплату", actionText: "Повторить") {
                    self?.payButtonTapped()
                })
            }
        }
    }
    
    @objc private func showAgreement() {
        guard let url = URL(string: "https://yandex.ru/legal/practicum_termsofuse/") else { return }
        let webViewController = WebViewController(url: url)
        webViewController.modalPresentationStyle = .pageSheet
        webViewController.modalTransitionStyle = .coverVertical
        present(webViewController, animated: true)
    }

    private func showSuccess() {
        let successVC = SuccessPaymentViewController(onReturnToCatalog: { [weak self] in
            self?.dismiss(animated: false) {
                self?.onSuccessPayment?()
            }
        })
        successVC.modalPresentationStyle = .fullScreen
        present(successVC, animated: true)
    }

    private func showFailure(retryAction: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: "Не удалось произвести оплату", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
            retryAction()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PaymentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentCell.reuseIdentifier, for: indexPath) as? PaymentCell else {
            return UICollectionViewCell()
        }
        
        let currency = currencies[indexPath.item]
        let isSelected = currency.id == selectedCurrencyId
        cell.configure(with: currency, isSelected: isSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previouslySelectedIndex = currencies.firstIndex { $0.id == selectedCurrencyId }
        selectedCurrencyId = currencies[indexPath.item].id
        
        payButton.isEnabled = true
        payButton.alpha = 1.0
        
        if let previouslySelectedIndex = previouslySelectedIndex {
            collectionView.reloadItems(at: [IndexPath(item: previouslySelectedIndex, section: 0)])
        }
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PaymentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 168, height: 46) // Фиксированный размер ячейки
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Фиксированные отступы для центрирования ячеек
        let totalWidth = collectionView.bounds.width
        let itemWidth: CGFloat = 168
        let itemsPerRow: CGFloat = 2
        let spacing: CGFloat = 7
        let totalItemWidth = (itemsPerRow * itemWidth) + (itemsPerRow - 1) * spacing
        let sideInset = max(0, (totalWidth - totalItemWidth) / 2)
        
        return UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
}
