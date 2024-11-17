import Foundation

typealias NftCompletion = (Result<Nft, Error>) -> Void

protocol NftService {
    func loadNft(id: String, completion: @escaping NftCompletion)
    func fetchCollections(completion: @escaping (Result<[NFTCollection], Error>) -> Void)
    func fetchNFTs(nftIDs: [String], completion: @escaping (Result<[Nft], Error>) -> Void)
}

final class NftServiceImpl: NftService {
 
    private let networkClient: NetworkClient
    private let storage: NftStorage

    init(networkClient: NetworkClient, storage: NftStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }

    func loadNft(id: String, completion: @escaping NftCompletion) {
        if let nft = storage.getNft(with: id) {
            completion(.success(nft))
            return
        }

        let request = NFTRequest(id: id)
        networkClient.send(request: request, type: Nft.self) { [weak storage] result in
            switch result {
            case .success(let nft):
                storage?.saveNft(nft)
                completion(.success(nft))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchCollections(completion: @escaping (Result<[NFTCollection], Error>) -> Void) {
        
        struct FetchCollectionsRequest: NetworkRequest {
            var endpoint: URL? {
                URL(string: "\(RequestConstants.baseURL)/api/v1/collections")
            }

            var httpMethod: HttpMethod {
                .get
            }

            var dto: Dto? {
                nil
            }
        }

        let request = FetchCollectionsRequest()
        print("Fetching collections from \(request.endpoint?.absoluteString ?? "Invalid URL")")
        networkClient.send(request: request, type: [NFTCollection].self) { result in
            print("Fetch result: \(result)")
            completion(result)
        }
    }
        
    func fetchNFTs(nftIDs: [String], completion: @escaping (Result<[Nft], Error>) -> Void) {
        var nfts: [Nft] = []
        var missingIds: [String] = []
        let dispatchGroup = DispatchGroup()

        // Проверяем локальное хранилище
        for id in nftIDs {
            if let cachedNft = storage.getNft(with: id) {
                nfts.append(cachedNft)
            } else {
                missingIds.append(id)
            }
        }

        if missingIds.isEmpty {
            completion(.success(nfts))
            return
        }

        for nftID in missingIds {
            dispatchGroup.enter()
            fetchSingleNft(id: nftID) { result in
                switch result {
                case .success(let nft):
                    nfts.append(nft)
                    self.storage.saveNft(nft)
                case .failure:
                    break
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(.success(nfts))
        }
    }

    private func fetchSingleNft(id: String, completion: @escaping (Result<Nft, Error>) -> Void) {
        struct FetchNftRequest: NetworkRequest {
            let nftID: String
            
            var endpoint: URL? {
                URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(nftID)")
            }
            
            var httpMethod: HttpMethod {
                .get
            }
            
            var headers: [String: String]? {
                ["Authorization": "Bearer \(RequestConstants.token)"]
            }
            
            var dto: Dto? {
                nil
            }
        }

        let request = FetchNftRequest(nftID: id)
        networkClient.send(request: request, type: Nft.self) { result in
            completion(result)
        }
    }
}
