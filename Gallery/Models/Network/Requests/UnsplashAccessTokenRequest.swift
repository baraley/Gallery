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
	
	// MARK: - NetworkRequest
	
	func decode(_ data: Data?, response: URLResponse?, error: Error?) -> Result<String, RequestError> {
		if let data = data,
			let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
			let accessToken = json[UnsplashQueryParameterName.accessToken] as? String {
			
			return .success(accessToken)
		}
		
		let error =	parseError(data, response: response, error: error)
		return .failure(error)
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
			UnsplashQueryParameterName.redirectURI:     UnsplashAPI.callbackUrlScheme,
			UnsplashQueryParameterName.code:   			code,
			UnsplashQueryParameterName.grantType:       UnsplashQueryParameterName.authorizationCode
		]
		for (key, value) in itemsDictionary {
			items.append(URLQueryItem(name: key, value: value))
		}
		
		return items
	}
	
	var headers: [String : String] = [:]
	
	var accessToken: String?
}
