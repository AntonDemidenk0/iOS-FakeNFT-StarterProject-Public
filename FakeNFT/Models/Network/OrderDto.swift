

import Foundation

struct OrderDto: Dto {
    let id: String
    let nfts: [String]

    init(order: Order) {
        self.id = order.id
        self.nfts = order.nfts
    }

    func asDictionary() -> [String: String] {
        return [
            "id": id,
            "nfts": nfts.joined(separator: ",")
        ]
    }
}
