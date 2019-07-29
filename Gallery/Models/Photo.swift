//
//  Model.swift
//  testAPI
//
//  Created by Alexander Baraley on 12/12/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import Foundation
import CoreGraphics

enum UnsplashSizeOfCrop: CGFloat {
	case regular = 1080
	case small = 400
	case thumb = 200
}

struct Photo: Decodable, ThumbURLHolder {
    
    let id: String
    let dataCreated: Date
    let descriptionText: String?
    let thumbURL: URL
    let imageURL: URL
    var isLiked: Bool
    var likes: Int
    let user: User
	let width: Float
	let height: Float
	let colorHex: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case dataCreated = "created_at"
        case descriptionText = "description"
        case urls
        case likedByUser = "liked_by_user"
        case likes
        case user
		case width
		case height
		case colorHex = "color"
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
        isLiked = try values.decode(Bool.self, forKey: .likedByUser)
        likes = try values.decode(Int.self, forKey: .likes)
        user = try values.decode(User.self, forKey: .user)
		width = try values.decode(Float.self, forKey: .width)
		height = try values.decode(Float.self, forKey: .height)
		colorHex = try values.decode(String.self, forKey: .colorHex)
        
        let urls = try values.nestedContainer(keyedBy: UrlsKey.self, forKey: .urls)
        thumbURL = try urls.decode(URL.self, forKey: .small)
        imageURL = try urls.decode(URL.self, forKey: .regular)
    }
	
	var sizeRatio: CGFloat {
		return CGFloat(height / width)
	}
	
	func croppedSize(to sizeOfCrop: UnsplashSizeOfCrop) -> CGSize {
		let ratio: CGFloat = CGFloat(height / width)
		let croppedWidth: CGFloat = sizeOfCrop.rawValue
		let croppedHeight: CGFloat = (croppedWidth * ratio).rounded()
		return CGSize(width: croppedWidth, height: croppedHeight)
	}
}

extension Photo: Equatable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id && lhs.dataCreated == rhs.dataCreated
    }
}

