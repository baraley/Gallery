//
//  PhotoRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/10/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation

struct PhotoListRequest: UnsplashRequest, Equatable {
	
	typealias PhotoListRequestResult = (photos: [Photo], totalPagesNumber: Int)
    
    var page: Int = 1
    private(set) var pageSize: UnsplashPageSize
    private let order: UnsplashPhotoListOrder
	
	init(pageSize: UnsplashPageSize = .small,
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
	
	private func parseTotalPages(from response: URLResponse?) -> Int {
		guard let httpResponse = response as? HTTPURLResponse,
			let photosNumberString = httpResponse.allHeaderFields["x-total"] as? String,
			let totalPhotos = Int(photosNumberString)
		else { return 1 }
		
		let approximately = Float(totalPhotos) / Float(pageSize.rawValue)
		
		return Int(approximately.rounded(FloatingPointRoundingRule.up))
	}
	
    // MARK: - NetworkRequest
	
	func decode(
		_ data: Data?, response: URLResponse?, error: Error?
		) -> Result<PhotoListRequestResult, RequestError> {
		
		let totalPages = parseTotalPages(from: response)
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		if let data = data, let photos = try? decoder.decode([Photo].self, from: data) {
			return .success((photos, totalPages))
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
        items.append(URLQueryItem(name: UnsplashQueryParameterName.page, value: "\(page)"))
        items.append(URLQueryItem(name: UnsplashQueryParameterName.perPage, value: "\(pageSize.rawValue)"))
        items.append(URLQueryItem(name: UnsplashQueryParameterName.orderedBy, value: order.rawValue))
        return items
    }
}
