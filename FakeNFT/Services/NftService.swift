import Foundation

typealias NftCompletion = (Result<Nft, Error>) -> Void

protocol NftService {
    func loadNft(id: String, completion: @escaping NftCompletion)
    func fetchCollections(completion: @escaping (Result<[NFTCollection], Error>) -> Void)
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
}
