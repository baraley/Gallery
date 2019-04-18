//
//  PhotoImageLoader.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/23/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class ImageLoader {
	
	private let networkManager: NetworkManager
	
	init(networkManager: NetworkManager) {
		self.networkManager = networkManager
	}
	
	func loadImage(from imageURL: URL, completionHandler: @escaping (NetworkResult<UIImage>) -> Void) {
		let imageRequest = ImageRequest(url: imageURL)
		
		networkManager.performRequest(imageRequest) { (result) in
			completionHandler(result)
		}
	}
	
	func cancelImageLoading(from imageURL: URL) {
		networkManager.cancel(ImageRequest(url: imageURL))
	}
}
