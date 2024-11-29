import Foundation

struct Profile: Codable {
    let id: String
    let avatar: String
    let name: String
    let description: String
    let website: String
    var likes: [String]
    var nfts: [String]
}
