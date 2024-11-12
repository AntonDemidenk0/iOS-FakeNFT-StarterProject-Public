//
//  Profile.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 11.11.24..
//

import Foundation

struct Profile: Codable {
    let name: String
    let avatar: String?
    let description: String?
    let website: String?
    let nfts: [String]
    let likes: [String]
    let id: String
}
