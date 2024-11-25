//
//  OrderModel.swift
//  FakeNFT
//
//  Created by GiyaDev on 22.11.2024.
//


import Foundation

struct Order: Codable {
    let id: String
    var nfts: [String]
}
