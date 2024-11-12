import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let imageCache = NSCache<NSString, UIImage>()

    private init() {}

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Failed to load image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to decode image data")
                completion(nil)
                return
            }

            self?.imageCache.setObject(image, forKey: NSString(string: urlString))

            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
