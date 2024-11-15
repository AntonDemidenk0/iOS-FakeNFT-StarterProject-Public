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
    let nfts: [String]
    let description: String
    let author: String
}

