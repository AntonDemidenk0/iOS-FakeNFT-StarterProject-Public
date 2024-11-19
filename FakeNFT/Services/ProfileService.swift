import Foundation


//struct FetchAuthorProfileRequest: NetworkRequest {
//    let endpoint: URL?
//    let httpMethod: HttpMethod = .get
//    let dto: Dto? = nil
//}
//
//
//final class ProfileService {
//    private let networkClient: NetworkClient
//
//    init(networkClient: NetworkClient) {
//        self.networkClient = networkClient
//    }
//
//    func fetchAuthorProfile(authorID: String, completion: @escaping (Result<ProfileModel, Error>) -> Void) {
//        guard !authorID.isEmpty else {
//            print("Error: Author ID is empty")
//            completion(.failure(NetworkClientError.invalidURL))
//            return
//        }
//        
//        let urlString = "\(RequestConstants.baseURL)/api/v1/profile/\(authorID)"
//        guard let url = URL(string: urlString) else {
//            print("Error: Invalid URL for author profile: \(urlString)")
//            completion(.failure(NetworkClientError.invalidURL))
//            return
//        }
//        
//        print("Fetching author profile from URL: \(url)")
//        
//        let request = FetchAuthorProfileRequest(endpoint: url)
//        networkClient.send(request: request, type: ProfileModel.self) { result in
//            print("Request result: \(result)")
//            completion(result)
//        }
//    }
//
//}




