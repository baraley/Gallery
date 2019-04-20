//
//  PhotosLoader.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/23/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

class PhotosLoader {
	
	private let networkManager: NetworkRequestPerformer
	private var photoListRequest: PhotoListRequest
	
	init(networkManager: NetworkRequestPerformer, photoListRequest: PhotoListRequest) {
		self.networkManager = networkManager
		self.photoListRequest = photoListRequest
	}
	
	private(set) var totalPages = 1
	
	var currentPage: Int  {
		get { return photoListRequest.page }
		set { photoListRequest.page = newValue }
	}
	
	func loadPhotos(_ completionHandler: @escaping (Result<[Photo], RequestError>) -> Void) {
		
		networkManager.performRequest(photoListRequest) { [weak self] (result) in
			switch result {
			case let .success(photoListRequestResult):
				
				self?.totalPages = photoListRequestResult.totalPagesNumber ?? 1
				self?.setupRequestForNextPage()
				
				completionHandler(.success(photoListRequestResult.photos))
				
			case let .failure(error):
				completionHandler(.failure(error))
			}
		}
	}
	
	private func setupRequestForNextPage() {
		if totalPages > photoListRequest.page {
			photoListRequest.page += 1
		}
	}
}
