//
//  ProfileModel.swift
//  FakeNFT
//
//  Created by GiyaDev on 23.11.2024.
//

import Foundation

import Foundation

struct Profile: Codable {
    let id: String
    let name: String
    let description: String
    let website: String
    var likes: [String]
    var nfts: [String]
}

