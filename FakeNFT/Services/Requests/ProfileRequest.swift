//
//  ProfileRequest.swift
//  FakeNFT
//
//  Created by Anton Demidenko on 11.11.24..
//

import Foundation

struct ProfileRequest: NetworkRequest {
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    
    var dto: Dto? { nil }
}

struct ProfilePutRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    var httpMethod: HttpMethod = .put
    var dto: Dto?
    
    var body: Data? {
        guard let dto = dto as? ProfileDtoObject else { return nil }
        return dto.asURLEncodedString().data(using: .utf8)
    }
    
    var headers: [String: String] {
        [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
    }
    
    init(dto: ProfileDtoObject) {
        self.dto = dto
    }
}

struct ProfileDtoObject: Dto {
    
    let name: String
    let description: String
    let website: String
    let avatar: String
    let likes: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case website
        case avatar
        case likes
    }
    
    func asDictionary() -> [String: String] {
        return [
            CodingKeys.name.rawValue: name.isEmpty ? "" : name,
            CodingKeys.description.rawValue: description.isEmpty ? "" : description,
            CodingKeys.website.rawValue: website.isEmpty ? "" : website,
            CodingKeys.avatar.rawValue: avatar.isEmpty ? "" : avatar,
            CodingKeys.likes.rawValue: likes.isEmpty ? "" : likes.joined(separator: ","),
        ]
    }
    
    func asURLEncodedString() -> String {
            asDictionary()
                .compactMap { key, value in
                    guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                          let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                        return nil
                    }
                    return "\(encodedKey)=\(encodedValue)"
                }
                .joined(separator: "&")
        }
    }
