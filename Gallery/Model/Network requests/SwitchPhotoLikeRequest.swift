//
//  LikePhotoRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/3/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation

struct SwitchPhotoLikeRequest: UnsplashRequest {
	
	typealias SwitchPhotoLikeResult = (isLiked: Bool, totalLikes: Int)
	
	init(photo: Photo, accessToken: String) {
		self.method = photo.liked ? .DELETE : .POST
		self.endpoint = "/photos/\(photo.id)/like"
		self.accessToken = accessToken
	}
	
	// MARK: - UnsplashRequest
	
	private(set) var method: HTTPMethod
	private(set) var endpoint: String
	private(set) var queryItems: [URLQueryItem] = []
	private(set) var accessToken: String?
	
	// MARK: - NetworkRequest
	
	func decode(_ data: Data, response: URLResponse?) -> SwitchPhotoLikeResult? {
		guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
			let photo = json["photo"] as? [String: Any],
			let liked = photo["liked_by_user"] as? Bool,
			let likes = photo["likes"] as? Int
		else { return nil }
		
		return (isLiked: liked, totalLikes: likes)
	}
}
