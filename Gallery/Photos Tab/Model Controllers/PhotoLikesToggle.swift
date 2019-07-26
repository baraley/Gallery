//
//  PhotoLikesToggle.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/23/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

class PhotoLikesToggle {
	
	private let networkService: NetworkService
	private let accessToken: String
	
	init(networkService: NetworkService, accessToken: String) {
		self.networkService = networkService
		self.accessToken = accessToken
	}
	
	func toggleLike(of photo: Photo, completionHandler: @escaping (Result<Photo, RequestError>) -> Void) {
		
		let toggleRequest = TogglePhotoLikeRequest(photo: photo, accessToken: accessToken)
		
		networkService.performRequest(toggleRequest) { (result) in
			completionHandler(result)
		}
	}
	
	func cancelLikeToggling(of photo: Photo) {
		let toggleRequest = TogglePhotoLikeRequest(photo: photo, accessToken: accessToken)
		
		networkService.cancel(toggleRequest)
	}
}
