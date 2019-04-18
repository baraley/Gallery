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
	
	func decode(_ data: Data, response: URLResponse?) -> String? {
		let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
		return json?[UnsplashQueryParameterName.accessToken] as? String
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
	
	var accessToken: String?
}
