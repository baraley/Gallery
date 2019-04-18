//
//  PhotosLoader.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/23/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

class PhotosLoader {
	
	private let networkManager: NetworkManager
	private var photoListRequest: PhotoListRequest
	
	init(networkManager: NetworkManager, photoListRequest: PhotoListRequest) {
		self.networkManager = networkManager
		self.photoListRequest = photoListRequest
	}
	
	private(set) var totalPages = 1
	
	var currentPage: Int  {
		get { return photoListRequest.page }
		set { photoListRequest.page = newValue }
	}
	
	func loadPhotos(_ completionHandler: @escaping ([Photo], String?) -> Void) {
		
		networkManager.performRequest(photoListRequest) { [weak self] (result) in
			switch result {
			case let .success(photoListRequestResult):
				
				self?.totalPages = photoListRequestResult.totalPagesNumber ?? 1
				self?.setupRequestForNextPage()
				
				completionHandler(photoListRequestResult.photos, nil)
				
			case let .failure(errorMessage):
				completionHandler([], errorMessage)
			}
		}
	}
	
	private func setupRequestForNextPage() {
		if totalPages > photoListRequest.page {
			photoListRequest.page += 1
		}
	}
}
