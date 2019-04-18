//
//  User.swift
//  testAPI
//
//  Created by Alexander Baraley on 12/17/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import Foundation

struct User: Decodable {
    let id: String
    let userName: String
    let name: String
    let biography: String?
    let totalLikes: Int
    let profileImageURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName = "username"
        case name
        case biography = "bio"
        case totalLikes = "total_likes"
        case profileImageURL = "profile_image"
    }
    
    enum ProfileImageKey: String, CodingKey {
        case small
        case medium
        case large
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)        
        id = try values.decode(String.self, forKey: .id)
        userName = try values.decode(String.self, forKey: .userName)
        name = try values.decode(String.self, forKey: .name)
        biography = try? values.decode(String.self, forKey: .biography)
        totalLikes = try values.decode(Int.self, forKey: .totalLikes)
        
        let profileImageURLs = try values.nestedContainer(keyedBy: ProfileImageKey.self,
                                                          forKey: .profileImageURL)
        profileImageURL = try profileImageURLs.decode(URL.self, forKey: .large)
    }
}
