//
//  UnsplashRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 5/26/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation

let defaultTimeoutInterval: TimeInterval = 10

protocol UnsplashRequest: NetworkRequest {
	
	var host: String { get }
	var method: HTTPMethod { get }
	var endpoint: String { get }
	var queryItems: [URLQueryItem] { get }
	var headers: [String: String] { get }
	
	var accessToken: String? { get }
}

extension UnsplashRequest {
	
	var host: String {
		return "api.unsplash.com"
	}
	
	var headers: [String: String] {
		var headers = ["Authorization": "Client-ID \(UnsplashAPI.clientID)"]
		if let token = accessToken {
			headers["Authorization"] = "Bearer \(token)"
		}
		return headers
	}
	
	var url: URL {
		var urlComponents = URLComponents()
		urlComponents.scheme = "https"
		urlComponents.host = host
		urlComponents.path = endpoint
		urlComponents.queryItems = queryItems
		return urlComponents.url!
	}
	
	var urlRequest: URLRequest {
		var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: defaultTimeoutInterval)
		
		request.httpMethod = method.rawValue
		request.allHTTPHeaderFields = headers
		
		return request
	}
}
