//
//  TogglePhotoLikeRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/3/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation

struct TogglePhotoLikeRequest: UnsplashRequest {
	
	private var photo: Photo
	
	init(photo: Photo, accessToken: String) {
		self.photo = photo
		self.method = photo.isLiked ? .DELETE : .POST
		self.endpoint = "/photos/\(photo.id)/like"
		self.accessToken = accessToken
	}
	
	// MARK: - UnsplashRequest
	
	private(set) var method: HTTPMethod
	private(set) var endpoint: String
	private(set) var queryItems: [URLQueryItem] = []
	private(set) var accessToken: String?
	
	// MARK: - NetworkRequest
	
	func decode(_ data: Data, response: URLResponse?) -> Photo? {
		guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
			let jsonPhoto = json["photo"] as? [String: Any],
			let isLiked = jsonPhoto["liked_by_user"] as? Bool,
			let likes = jsonPhoto["likes"] as? Int
		else { return nil }
		
		var newPhoto = photo
		newPhoto.isLiked = isLiked
		newPhoto.likes = likes

		return newPhoto
	}
}
