//
//  CartModel.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 11.11.2024.
//

import Foundation

struct CartItem: Decodable {
    let id: String
    let name: String
    let price: Double
    let rating: Int
    let description: String
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case rating
        case description
        case images
    }
    
    // Декодируем первый URL из массива `images`
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        rating = try container.decode(Int.self, forKey: .rating)
        description = try container.decode(String.self, forKey: .description)
        
        // Попробуем получить первый элемент из массива изображений
        let images = try container.decodeIfPresent([String].self, forKey: .images)
        imageUrl = images?.first
    }
}
