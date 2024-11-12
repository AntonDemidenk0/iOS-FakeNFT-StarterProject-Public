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
