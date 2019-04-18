//
//  UnsplashAccessTokenRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 5/28/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation

struct UnsplashAccessTokenRequest: UnsplashRequest {
		
	private let code: String
	
	init(authorizationCode: String) {
		code = authorizationCode
	}
	
	// MARK: - UnsplashRequest
	
	var host = "unsplash.com"
	var method = HTTPMethod.POST
	var endpoint = "/oauth/token"
	
	var queryItems: [URLQueryItem] {
		var items = [URLQueryItem]()
		
		let itemsDictionary = [
			UnsplashQueryParameterName.clientID:        UnsplashAPI.clientID,
			UnsplashQueryParameterName.clientSecret:	UnsplashAPI.clientSecret,
			UnsplashQueryParameterName.redirectURI:     UnsplashAPI.redirectURI,
			UnsplashQueryParameterName.code:   			code,
			UnsplashQueryParameterName.grantType:       UnsplashQueryParameterName.authorizationCode
		]
		for (key, value) in itemsDictionary {
			items.append(URLQueryItem(name: key, value: value))
		}
		
		return items
	}
	
	var headers: [String : String] = [:]
	
	// MARK: - NetworkRequest
	
	var accessToken: String? = nil
	
	var urlRequest: URLRequest {
		var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: defaultTimeoutInterval)
		request.httpMethod = HTTPMethod.POST.rawValue
		return request
	}
	
	func decode(_ data: Data, response: URLResponse?) -> String? {
		if let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
			return json[UnsplashQueryParameterName.accessToken] as? String
		}
		return nil
	}
}
