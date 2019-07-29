//
//  PhotoCollectionListRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/19/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

struct PhotoCollectionListRequest: UnsplashRequest, PaginalRequest {
	typealias ContentModel = PhotoCollection
	
	var page: Int = 1
	private(set) var pageSize: UnsplashPageSize
	
	init(pageSize: UnsplashPageSize = .large, accessToken: String? = nil) {
		
		self.pageSize = pageSize
		self.accessToken = accessToken
	}
	
	// MARK: - NetworkRequest
	
	func decode(
		_ data: Data?, response: URLResponse?, error: Error?
		) -> Result<[PhotoCollection], RequestError> {
		
		
		let decoder = JSONDecoder()
		
		if let data = data, let photoCollections = try? decoder.decode([PhotoCollection].self, from: data) {
			return .success(photoCollections)
		}
		
		let error =	parseError(data, response: response, error: error)
		return .failure(error)
	}
	
	// MARK: - UnsplashRequest
	
	private(set) var accessToken: String?
	
	private(set) var method = HTTPMethod.GET
	private(set) var endpoint: String = "/collections"
	
	var queryItems: [URLQueryItem] {
		var items = [URLQueryItem]()
		items.append(URLQueryItem(name: UnsplashParameterName.Pagination.page, value: "\(page)"))
		items.append(URLQueryItem(name: UnsplashParameterName.Pagination.perPage, value: "\(pageSize.rawValue)"))
		return items
	}
}
