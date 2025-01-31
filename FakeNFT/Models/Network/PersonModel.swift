import UIKit

struct Person: Decodable {
    
    let name: String
    let avatar: String
    let description: String
    let website: String
    let nfts: [String]
    let rating, id: String
}
