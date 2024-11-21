import Foundation

final class ProfileNFTService {
    
    // MARK: - Singleton
    
    static let shared = ProfileNFTService()
    private init() {}
    
    // MARK: - Properties
    
    var nftsIDs: [String] = []
    var visibleNFT: [NFTModel] = []
    
    // MARK: - Public Methods
    
    func getNFT(completion: @escaping () -> Void) {
        guard !nftsIDs.isEmpty else {
            print("No NFT IDs to fetch.")
            completion()
            return
        }
        
        visibleNFT.removeAll()
        let dispatchGroup = DispatchGroup()
        
        nftsIDs.forEach { id in
            guard let request = createRequest(for: id) else {
                print("Invalid URL for NFT ID: \(id)")
                return
            }
            
            dispatchGroup.enter()
            fetchNFT(request: request) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .success(let nft):
                    self?.visibleNFT.append(nft)
                case .failure(let error):
                    print("Failed to fetch NFT for ID \(id): \(error.localizedDescription)")
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("All NFT fetch operations completed. Total NFTs: \(self.visibleNFT.count)")
            completion()
        }
    }
    
    func getProfile(completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        guard let url = URL(string: "\(NetworkConstants.baseURL)/api/v1/profile/1") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let request = createRequest(url: url)
        fetchProfile(request: request, completion: completion)
    }
    
    // MARK: - Private Methods
    
    private func createRequest(for id: String) -> URLRequest? {
        guard let url = URL(string: "\(NetworkConstants.baseURL)/api/v1/nft/\(id)") else { return nil }
        return createRequest(url: url)
    }
    
    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue(NetworkConstants.acceptValue, forHTTPHeaderField: NetworkConstants.acceptKey)
        request.addValue(NetworkConstants.tokenValue, forHTTPHeaderField: NetworkConstants.tokenKey)
        return request
    }
    
    private func fetchNFT(request: URLRequest, completion: @escaping (Result<NFTModel, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let nftModel = try JSONDecoder().decode(NFTModel.self, from: data)
                completion(.success(nftModel))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func fetchProfile(request: URLRequest, completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let profile = try JSONDecoder().decode(ProfileModel.self, from: data)
                completion(.success(profile))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
