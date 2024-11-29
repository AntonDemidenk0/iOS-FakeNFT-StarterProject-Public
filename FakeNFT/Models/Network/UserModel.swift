//
//  ProfileModel.swift
//  FakeNFT
//
//  Created by GiyaDev on 19.11.2024.
//

import Foundation

struct UserModel: Codable {
    let name: String?
    let avatar: String?
    let description: String?
    let website: String?
    let nfts: [String]?
    let rating: String?
    let id: String
}

