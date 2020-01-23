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
	private var searchQuery: String = ""
	
	init(pageSize: UnsplashPageSize = .large, accessToken: String? = nil) {
		
		self.pageSize = pageSize
		self.accessToken = accessToken
		
		endpoint = "/collections"
	}
	
	init(featuredCollectionsWithPageSize pageSize: UnsplashPageSize, accessToken: String? = nil) {
		
		self.init(pageSize: pageSize, accessToken: accessToken)
		endpoint = "/collections/featured"
	}
	
	init(searchQuery: String,
		 pageSize: UnsplashPageSize = .large,
		 accessToken: String? = nil) {
		
		self.init(pageSize: pageSize, accessToken: accessToken)
		
		self.searchQuery = searchQuery
		endpoint = "/search/collections"
	}
	
	// MARK: - NetworkRequest
	
	func decode(
		_ data: Data?, response: URLResponse?, error: Error?
		) -> Result<[PhotoCollection], RequestError> {
		
		if let data = data {
			let decoder = JSONDecoder()
			
			if searchQuery.isEmpty, let photoCollections = try? decoder.decode([PhotoCollection].self,
																			   from: data) {
				return .success(photoCollections)
				
			} else if let searchResults = try? decoder.decode(SearchPhotoCollectionsResult.self,
															  from: data) {
				return .success(searchResults.results)
			}
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
		if !searchQuery.isEmpty {
			items.append(URLQueryItem(name: UnsplashParameterName.ListRequest.query, value: searchQuery))
		}
		items.append(URLQueryItem(name: UnsplashParameterName.ListRequest.page, value: "\(page)"))
		items.append(URLQueryItem(name: UnsplashParameterName.ListRequest.perPage, value: "\(pageSize.rawValue)"))
		return items
	}
}
