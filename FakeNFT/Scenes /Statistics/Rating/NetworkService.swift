import UIKit

final class StatisticService {
    
    static let didChangeNotification = Notification.Name("StatisticServiceDidChange")
    static let shared = StatisticService()
    
    private init() {}
    
    private(set) var users: [Person] = []
    private var lastLoadedPage = 0
    
    // MARK: - Public Methods
    
    func fetchNextPage() {
        guard let url = buildURL(forPage: lastLoadedPage) else {
            print("Invalid URL")
            return
        }
        
        let request = buildRequest(withURL: url)
        fetchData(from: request)
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
    
    private func fetchData(from request: URLRequest) {
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("Request failed with error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                self.handleResponse(data)
            }
        }
        task.resume()
    }
    
    private func handleResponse(_ data: Data) {
        do {
            let users = try JSONDecoder().decode([Person].self, from: data)
            self.users.append(contentsOf: users.sorted { $0.nfts.count > $1.nfts.count })
            lastLoadedPage += 1
            NotificationCenter.default.post(name: StatisticService.didChangeNotification, object: self)
        } catch {
            print("Failed to decode response: \(error.localizedDescription)")
        }
    }
}
