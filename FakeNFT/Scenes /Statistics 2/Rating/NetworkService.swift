import UIKit

final class StatisticService {
    
    static let shared = StatisticService()
    
    private init() {}
    
    private(set) var users: [Person] = []
    private var lastLoadedPage = 0
    
    // MARK: - Public Methods
    
    func fetchNextPage(completion: @escaping (Result<[Person], Error>) -> Void) {
        guard let url = buildURL(forPage: lastLoadedPage) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let request = buildRequest(withURL: url)
        fetchData(from: request, completion: completion)
    }
    
    // MARK: - Private Methods
    
    private func buildURL(forPage page: Int) -> URL? {
        let urlString = "\(NetworkConstants.baseURL)/api/v1/users?page=\(page)"
        return URL(string: urlString)
    }
    
    private func buildRequest(withURL url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue(NetworkConstants.acceptValue, forHTTPHeaderField: NetworkConstants.acceptKey)
        request.addValue(NetworkConstants.tokenValue, forHTTPHeaderField: NetworkConstants.tokenKey)
        return request
    }
    
    private func fetchData(from request: URLRequest, completion: @escaping (Result<[Person], Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                self.handleResponse(data, completion: completion)
            }
        }
        task.resume()
    }
    
    private func handleResponse(_ data: Data, completion: @escaping (Result<[Person], Error>) -> Void) {
        do {
            let users = try JSONDecoder().decode([Person].self, from: data)
            let sortedUsers = users.sorted { $0.nfts.count > $1.nfts.count }
            self.users.append(contentsOf: sortedUsers)
            lastLoadedPage += 1
            completion(.success(sortedUsers))
        } catch {
            completion(.failure(error))
        }
    }
}
