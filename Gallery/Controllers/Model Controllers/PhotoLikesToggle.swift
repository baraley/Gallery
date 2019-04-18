//
//  PhotoLikesToggle.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/23/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

class PhotoLikesToggle {
	
	private let networkManager: NetworkManager
	private let accessToken: String
	
	init(networkManager: NetworkManager, accessToken: String) {
		self.networkManager = networkManager
		self.accessToken = accessToken
	}
	
	func toggleLike(of photo: Photo, completionHandler: @escaping (NetworkResult<Photo>) -> Void) {
		
		let toggleRequest = TogglePhotoLikeRequest(photo: photo, accessToken: accessToken)
		
		networkManager.performRequest(toggleRequest) { (result) in
			
			completionHandler(result)
		}
	}
	
	func cancelLikeToggling(of photo: Photo) {
		let toggleRequest = TogglePhotoLikeRequest(photo: photo, accessToken: accessToken)
		
		networkManager.cancel(toggleRequest)
	}
}
