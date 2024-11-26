//
//  ProfileDto.swift
//  FakeNFT
//
//  Created by GiyaDev on 23.11.2024.
//

import Foundation

import Foundation

struct ProfileDto: Dto {
    let id: String
    let name: String
    let description: String
    let website: String
    let likes: [String]
    let nfts: [String]

    init(profile: Profile) {
        self.id = profile.id
        self.name = profile.name
        self.description = profile.description
        self.website = profile.website
        self.likes = profile.likes
        self.nfts = profile.nfts
    }

    func asDictionary() -> [String: String] {
        return [
            "id": id,
            "name": name,
            "description": description,
            "website": website,
            "likes": likes.joined(separator: ","),
            "nfts": nfts.joined(separator: ",")
        ]
    }
}

