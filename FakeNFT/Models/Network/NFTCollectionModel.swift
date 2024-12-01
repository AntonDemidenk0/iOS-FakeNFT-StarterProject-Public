//
//  NFTCollection.swift
//  FakeNFT
//
//  Created by GiyaDev on 10.11.2024.
//

import Foundation

struct NFTCollection: Decodable, Equatable {
    let id: String
    let name: String
    let cover: String
    var nfts: [String]
    let description: String
    let author: String

    static func == (lhs: NFTCollection, rhs: NFTCollection) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.cover == rhs.cover &&
               lhs.nfts == rhs.nfts &&
               lhs.description == rhs.description &&
               lhs.author == rhs.author
    }
}
