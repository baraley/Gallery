//
//  PagesNumberRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/21/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

struct PagesNumberRequest: UnsplashRequest {
	
	private var pageSize: UnsplashPageSize
	
	init<R: PaginalRequest>(from request: R) {
		
		pageSize = request.pageSize
		accessToken = request.accessToken
		method = request.method
		endpoint = request.endpoint
	}
	
	// MARK: - NetworkRequest
	
	func decode(
		_ data: Data?, response: URLResponse?, error: Error?
		) -> Result<Int, RequestError> {
		
		let totalPages = parseTotalPages(from: response)

		return .success(totalPages)
	}
	// MARK: - UnsplashRequest
	
	private(set) var accessToken: String?
	
	private(set) var method: HTTPMethod
	private(set) var endpoint: String
	
	var queryItems: [URLQueryItem] {
		var items = [URLQueryItem]()
		items.append(URLQueryItem(name: UnsplashParameterName.ListRequest.perPage, value: "\(pageSize.rawValue)"))
		return items
	}
	
	// MARK: - Private
	
	private func parseTotalPages(from response: URLResponse?) -> Int {
		guard let httpResponse = response as? HTTPURLResponse,
			let photosNumberString = httpResponse.allHeaderFields["x-total"] as? String,
			let totalPhotos = Int(photosNumberString)
			else { return 1 }
		
		let approximately = Float(totalPhotos) / Float(pageSize.rawValue)
		
		return Int(approximately.rounded(FloatingPointRoundingRule.up))
	}
}
