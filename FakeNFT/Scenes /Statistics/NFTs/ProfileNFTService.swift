import Foundation

final class ProfileNFTService {
    
    // MARK: - Singleton
    static let shared = ProfileNFTService()
    private init() {}
    
    // MARK: - Properties
    private var nftsIDs: [String] = []
    private var visibleNFTs: [Nft] = []
    private var currentNFT: Nft?
    
    // MARK: - Public Methods
    
    func fetchNFTs(for ids: [String], completion: @escaping (Result<[Nft], Error>) -> Void) {
        guard !ids.isEmpty else {
            logError("No NFT IDs provided for fetching.")
            completion(.success([]))
            return
        }
        
        visibleNFTs.removeAll()
        let dispatchGroup = DispatchGroup()
        
        ids.forEach { id in
            guard let request = makeRequest(for: id) else {
                logError("Failed to create request for NFT ID: \(id)")
                return
            }
            
            dispatchGroup.enter()
            fetchData(request: request) { [weak self] (result: Result<Nft, Error>) in
                defer { dispatchGroup.leave() }
                switch result {
                case .success(let nft):
                    self?.visibleNFTs.append(nft)
                case .failure(let error):
                    self?.logError("Failed to fetch NFT \(id): \(error.localizedDescription)")
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(self.visibleNFTs))
        }
    }
    
    func fetchProfile(completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        guard let request = makeRequest(forPath: "/api/v1/profile/1") else {
            completion(.failure(ServiceError.invalidURL))
            return
        }
        fetchData(request: request, completion: completion)
    }
    
    func updateLikes(newLikes: [String], profile: ProfileModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentNFT = currentNFT else {
            logError("Current NFT is not set.")
            return
        }
        
        let endpoint = "/api/v1/profile/1"
        let parameters: [String: String] = profile.likes.count == 1 && profile.likes.contains(currentNFT.id)
        ? ["likes": "null"]
        : ["likes": newLikes.joined(separator: ",")]
        
        updateData(endpoint: endpoint, parameters: parameters, completion: completion)
    }
    
    func fetchCart(completion: @escaping (Result<Cart, Error>) -> Void) {
        guard let request = makeRequest(forPath: "/api/v1/orders/1") else {
            completion(.failure(ServiceError.invalidURL))
            return
        }
        fetchData(request: request, completion: completion)
    }
    
    func updateCart(newCart: [String], cart: Cart, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentNFT = currentNFT else {
            logError("Current NFT is not set.")
            return
        }
        
        let endpoint = "/api/v1/orders/1"
        let parameters: [String: String] = cart.nfts.count == 1 && cart.nfts.first == currentNFT.id
        ? [:]
        : ["nfts": newCart.joined(separator: ",")]
        
        updateData(endpoint: endpoint, parameters: parameters, completion: completion)
    }
    
    func setCurrentNFT(_ nft: Nft) {
        self.currentNFT = nft
    }
    
    // MARK: - Private Methods
    
    private func makeRequest(for id: String) -> URLRequest? {
        makeRequest(forPath: "/api/v1/nft/\(id)")
    }
    
    private func makeRequest(forPath path: String) -> URLRequest? {
        guard let url = URL(string: "\(NetworkConstants.baseURL)\(path)") else { return nil }
        return buildRequest(for: url)
    }
    
    private func buildRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue(NetworkConstants.acceptValue, forHTTPHeaderField: NetworkConstants.acceptKey)
        request.addValue(NetworkConstants.tokenValue, forHTTPHeaderField: NetworkConstants.tokenKey)
        return request
    }
    
    private func fetchData<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ServiceError.noData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func updateData(endpoint: String, parameters: [String: String], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(NetworkConstants.baseURL)\(endpoint)") else {
            completion(.failure(ServiceError.invalidURL))
            return
        }
        
        var request = buildRequest(for: url)
        request.httpMethod = "PUT"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(ServiceError.serverError))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    private func logError(_ message: String) {
        print("[Error] \(message)")
    }
}

// MARK: - Supporting Types

enum ServiceError: Error {
    case invalidURL
    case noData
    case serverError
}
