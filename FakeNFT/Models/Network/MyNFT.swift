//
//  MyNFT.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 14.11.24..
//

struct MyNFT: Decodable {
    let id: String
    let name: String
    let images: [String]
    let rating: Int
    let price: Float
    let author: String
}
