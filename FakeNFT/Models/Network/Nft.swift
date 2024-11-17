import Foundation

//struct Nft: Decodable, Equatable {
//    let id: String
//    let images: [URL]
//}

struct Nft: Decodable {
    let id: String
    let name: String
    let images: [String]
    let rating: Int
    let description: String
    let price: Double
    let author: String

    var imageUrls: [URL] {
        images.compactMap { URL(string: $0) }
    }
}



