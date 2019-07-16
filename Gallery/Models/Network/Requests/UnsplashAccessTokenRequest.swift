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
			let accessToken = json[UnsplashParameterName.Authentication.accessToken] as? String {
			
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
			UnsplashParameterName.Authentication.clientID:      UnsplashAPI.clientID,
			UnsplashParameterName.Authentication.clientSecret:	UnsplashAPI.clientSecret,
			UnsplashParameterName.Authentication.redirectURI:   UnsplashAPI.callbackUrlScheme,
			UnsplashParameterName.Authentication.code:   		code,
			UnsplashParameterName.Authentication.grantType:     UnsplashParameterName.Authentication.authorizationCode
		]
		for (key, value) in itemsDictionary {
			items.append(URLQueryItem(name: key, value: value))
		}
		
		return items
	}
	
	var headers: [String : String] = [:]
	
	var accessToken: String?
}
