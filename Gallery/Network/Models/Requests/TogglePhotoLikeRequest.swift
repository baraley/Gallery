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
	func decode(_ data: Data?, response: URLResponse?, error: Error?) -> Result<Photo, RequestError> {
		
		if let data = data,
			let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
			let jsonPhoto = json["photo"] as? [String: Any],
			let isLiked = jsonPhoto["liked_by_user"] as? Bool,
			let likes = jsonPhoto["likes"] as? Int {
			
			var newPhoto = photo
			newPhoto.isLiked = isLiked
			newPhoto.likes = likes
			
			return .success(newPhoto)
		}
		
		let error =	parseError(data, response: response, error: error)
		return .failure(error)
	}
}
