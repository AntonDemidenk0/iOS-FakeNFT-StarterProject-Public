import Foundation

// MARK: - Protocol

typealias NftCompletion = (Result<Nft, Error>) -> Void

protocol NftService {
    func loadNft(id: String, completion: @escaping NftCompletion)
    func fetchCollections(completion: @escaping (Result<[NFTCollection], Error>) -> Void)
    func fetchNFTs(nftIDs: [String], completion: @escaping (Result<[Nft], Error>) -> Void)
    func fetchOrder(completion: @escaping (Result<Order, Error>) -> Void)
    func updateOrder(_ order: Order, completion: @escaping (Result<Order, Error>) -> Void)
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void)
    func updateProfile(_ profile: Profile, completion: @escaping (Result<Profile, Error>) -> Void)
}

// MARK: - Implementation

final class NftServiceImpl: NftService {
    
    // MARK: - Private Properties
    
    private let networkClient: NetworkClient
    private let storage: NftStorage
    
    // MARK: - Initialization
    
    init(networkClient: NetworkClient, storage: NftStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }
    
    // MARK: - Public Methods
    
    func loadNft(id: String, completion: @escaping NftCompletion) {
        if let nft = storage.getNft(with: id) {
            print("[LoadNFT] NFT найден в кеше: \(id)")
            completion(.success(nft))
            return
        }
        
        let request = NFTRequest(id: id)
        print("[LoadNFT] Отправка запроса для загрузки NFT: \(id)")
        networkClient.send(request: request, type: Nft.self) { [weak storage] result in
            switch result {
            case .success(let nft):
                print("[LoadNFT] Успешная загрузка NFT: \(nft.id)")
                storage?.saveNft(nft)
                completion(.success(nft))
            case .failure(let error):
                print("[LoadNFT] Ошибка при загрузке NFT: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func fetchCollections(completion: @escaping (Result<[NFTCollection], Error>) -> Void) {
        struct FetchCollectionsRequest: NetworkRequest {
            var endpoint: URL? {
                URL(string: "\(RequestConstants.baseURL)/api/v1/collections")
            }
            var httpMethod: HttpMethod { .get }
            var dto: Dto? { nil }
        }
        
        let request = FetchCollectionsRequest()
        print("[FetchCollections] URL: \(request.endpoint?.absoluteString ?? "URL отсутствует")")
        networkClient.send(request: request, type: [NFTCollection].self) { result in
            switch result {
            case .success(let collections):
                print("[FetchCollections] Успешно загружено \(collections.count) коллекций")
                completion(.success(collections))
            case .failure(let error):
                print("[FetchCollections] Ошибка при загрузке коллекций: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func fetchNFTs(nftIDs: [String], completion: @escaping (Result<[Nft], Error>) -> Void) {
        var nfts: [Nft] = []
        var missingIds: [String] = []
        let dispatchGroup = DispatchGroup()
        var fetchErrors: [Error] = []
        
        print("[FetchNFTs] Начало загрузки NFT: \(nftIDs)")
        
        for id in nftIDs {
            if let cachedNft = storage.getNft(with: id) {
                nfts.append(cachedNft)
                print("[FetchNFTs] NFT найден в кеше: \(id)")
            } else {
                missingIds.append(id)
            }
        }
        
        if missingIds.isEmpty {
            print("[FetchNFTs] Все NFT найдены в кеше")
            completion(.success(nfts))
            return
        }
        
        print("[FetchNFTs] Не найдено в кеше, требуется загрузка: \(missingIds)")
        for nftID in missingIds {
            dispatchGroup.enter()
            fetchSingleNft(id: nftID) { result in
                switch result {
                case .success(let nft):
                    nfts.append(nft)
                    self.storage.saveNft(nft)
                    print("[FetchNFTs] Успешная загрузка NFT: \(nft.id)")
                case .failure(let error):
                    fetchErrors.append(error)
                    print("[FetchNFTs] Ошибка при загрузке NFT: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !fetchErrors.isEmpty {
                print("[FetchNFTs] Завершено с ошибками")
                completion(.failure(fetchErrors.first!))
            } else {
                print("[FetchNFTs] Успешно загружено \(nfts.count) NFT")
                completion(.success(nfts))
            }
        }
    }
    
    func fetchOrder(completion: @escaping (Result<Order, Error>) -> Void) {
        struct FetchOrderRequest: NetworkRequest {
            var endpoint: URL? {
                URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
            }
            var httpMethod: HttpMethod { .get }
            var dto: Dto? { nil }
        }
        
        let request = FetchOrderRequest()
        print("[FetchOrder] URL: \(request.endpoint?.absoluteString ?? "URL отсутствует")")
        networkClient.send(request: request, type: Order.self, onResponse: completion)
    }

    func updateOrder(_ order: Order, completion: @escaping (Result<Order, Error>) -> Void) {
        struct UpdateOrderRequest: NetworkRequest {
            let order: Order
            var endpoint: URL? {
                URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
            }
            var httpMethod: HttpMethod { .put }
            var headers: [String: String]? {
                [
                    "Authorization": "Bearer \(RequestConstants.token)",
                    "Content-Type": "application/json"
                ]
            }
            var dto: Dto? {
                OrderDto(order: order)
            }
        }
        
        let request = UpdateOrderRequest(order: order)
        if let dto = request.dto as? OrderDto {
            print("[UpdateOrder] Отправляем запрос: \(dto.asDictionary())")
        }
        networkClient.send(request: request, type: Order.self, onResponse: completion)
    }

    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        struct FetchProfileRequest: NetworkRequest {
            var endpoint: URL? {
                URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
            }
            var httpMethod: HttpMethod { .get }
            var dto: Dto? { nil }
        }
        
        let request = FetchProfileRequest()
        print("[FetchProfile] URL: \(request.endpoint?.absoluteString ?? "URL отсутствует")")
        networkClient.send(request: request, type: Profile.self, onResponse: completion)
    }

    func updateProfile(_ profile: Profile, completion: @escaping (Result<Profile, Error>) -> Void) {
        struct UpdateProfileRequest: NetworkRequest {
            let profile: Profile
            var endpoint: URL? {
                URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
            }
            var httpMethod: HttpMethod { .put }
            var headers: [String: String]? {
                [
                    "Authorization": "Bearer \(RequestConstants.token)",
                    "Content-Type": "application/json"
                ]
            }
            var dto: Dto? {
                ProfileDto(profile: profile)
            }
        }
        
        let request = UpdateProfileRequest(profile: profile)
        if let dto = request.dto as? ProfileDto {
            print("[UpdateProfile] Отправляем запрос: \(dto.asDictionary())")
        }
        networkClient.send(request: request, type: Profile.self) { result in
            switch result {
            case .success(let updatedProfile):
                print("[UpdateProfile] Успешное обновление профиля: \(updatedProfile.likes)")
                completion(.success(updatedProfile))
            case .failure(let error):
                print("[UpdateProfile] Ошибка при обновлении профиля: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchSingleNft(id: String, completion: @escaping (Result<Nft, Error>) -> Void) {
        struct FetchNftRequest: NetworkRequest {
            let nftID: String
            var endpoint: URL? {
                URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(nftID)")
            }
            var httpMethod: HttpMethod { .get }
            var headers: [String: String]? {
                ["Authorization": "Bearer \(RequestConstants.token)"]
            }
            var dto: Dto? { nil }
        }
        
        let request = FetchNftRequest(nftID: id)
        print("[FetchSingleNft] URL: \(request.endpoint?.absoluteString ?? "URL отсутствует")")
        networkClient.send(request: request, type: Nft.self, onResponse: completion)
    }
}
