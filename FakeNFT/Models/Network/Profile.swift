//
//  Profile.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 11.11.24..
//

import Foundation

struct Profile: Codable {
    var name: String?
    var avatar: String?
    var description: String?
    var website: String?
    var nfts: [String]
    var likes: [String]
    var id: String
}
