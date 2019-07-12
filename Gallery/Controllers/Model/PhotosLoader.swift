//
//  PhotosLoader.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/23/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

class PhotosLoader: Equatable {
	
	static func == (lhs: PhotosLoader, rhs: PhotosLoader) -> Bool {
		return lhs.photoListRequest == rhs.photoListRequest &&
			lhs.currentPage == rhs.currentPage &&
			lhs.totalPages == rhs.totalPages
	}
	
	private let networkService: NetworkService
	private var photoListRequest: PhotoListRequest
	
	init(networkService: NetworkService, photoListRequest: PhotoListRequest) {
		self.networkService = networkService
		self.photoListRequest = photoListRequest
	}
	
	private(set) var totalPages = 1
	
	var currentPage: Int  {
		get { return photoListRequest.page }
		set { photoListRequest.page = newValue }
	}
	
	func loadPhotos(_ completionHandler: @escaping (Result<[Photo], RequestError>) -> Void) {
		
		networkService.performRequest(photoListRequest) { [weak self] (result) in
			switch result {
			case let .success(photoListRequestResult):
				
				self?.totalPages = photoListRequestResult.totalPagesNumber
				self?.setupRequestForNextPage()
				
				completionHandler(.success(photoListRequestResult.photos))
				
			case .failure(let error):
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
