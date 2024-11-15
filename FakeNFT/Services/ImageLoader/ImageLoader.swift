import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let imageCache = NSCache<NSString, UIImage>()

    private init() {}

    func loadImage(from urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            completion(.success(cachedImage))
            return
        }

        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURLString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(NSError(domain: "Failed to load image", code: -2, userInfo: nil)))
                return
            }

            self?.imageCache.setObject(image, forKey: NSString(string: urlString))
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }.resume()
    }
}
