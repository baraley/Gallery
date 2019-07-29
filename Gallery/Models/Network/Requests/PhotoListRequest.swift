//
//  PhotoRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/10/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation

struct PhotoListRequest: UnsplashRequest, Equatable, PaginalRequest {
	typealias ContentModel = Photo
	
    var page: Int = 1
    private(set) var pageSize: UnsplashPageSize
    private let order: UnsplashPhotoListOrder
	
	init(pageSize: UnsplashPageSize = .large,
         order: UnsplashPhotoListOrder = .latest,
         accessToken: String? = nil) {
        
        self.pageSize = pageSize
        self.order = order
        self.accessToken = accessToken
		
		endpoint = "/photos"
    }
	
	init(likedPhotosOfUser userName: String,
		 pageSize: UnsplashPageSize = .large,
		 order: UnsplashPhotoListOrder = .latest,
		 accessToken: String) {
	
		self.init(pageSize: pageSize, order: order, accessToken: accessToken)
		
		endpoint = "/users/\(userName)/likes"
	}
	
	init(photosFromCollection photoCollection: PhotoCollection,
		 pageSize: UnsplashPageSize = .large,
		 order: UnsplashPhotoListOrder = .latest,
		 accessToken: String? = nil) {
		
		self.init(pageSize: pageSize, order: order, accessToken: accessToken)
		
		endpoint = "/collections/\(photoCollection.id)/photos"
	}
	
    // MARK: - NetworkRequest
	
	func decode(
		_ data: Data?, response: URLResponse?, error: Error?
		) -> Result<[Photo], RequestError> {
				
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		if let data = data, let photos = try? decoder.decode([Photo].self, from: data) {
			return .success(photos)
		}
		
		let error =	parseError(data, response: response, error: error)
		return .failure(error)
	}
	
    // MARK: - UnsplashRequest
    
    private(set) var accessToken: String?
    
    private(set) var method = HTTPMethod.GET
	private(set) var endpoint: String
    
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        items.append(URLQueryItem(name: UnsplashParameterName.Pagination.page, value: "\(page)"))
        items.append(URLQueryItem(name: UnsplashParameterName.Pagination.perPage, value: "\(pageSize.rawValue)"))
        items.append(URLQueryItem(name: UnsplashParameterName.Pagination.orderedBy, value: order.rawValue))
        return items
    }
}
