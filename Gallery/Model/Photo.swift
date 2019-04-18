//
//  Model.swift
//  testAPI
//
//  Created by Alexander Baraley on 12/12/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import Foundation

struct Photo: Decodable {
    
    let id: String
    let dataCreated: Date
    let descriptionText: String?
    let thumbURL: URL
    let imageURL: URL
    var liked: Bool
    var likes: Int
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case id
        case dataCreated = "created_at"
        case descriptionText = "description"
        case urls
        case likedByUser = "liked_by_user"
        case likes
        case user
    }
    
    enum UrlsKey: String, CodingKey {
        case thumb
        case small
        case regular
        case full
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        dataCreated = try values.decode(Date.self, forKey: .dataCreated)
        descriptionText = try? values.decode(String.self, forKey: .descriptionText)
        liked = try values.decode(Bool.self, forKey: .likedByUser)
        likes = try values.decode(Int.self, forKey: .likes)
        user = try values.decode(User.self, forKey: .user)
        
        let urls = try values.nestedContainer(keyedBy: UrlsKey.self, forKey: .urls)
        thumbURL = try urls.decode(URL.self, forKey: .small)
        imageURL = try urls.decode(URL.self, forKey: .regular)
    }
}

extension Photo: Equatable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
}

