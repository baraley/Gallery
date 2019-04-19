//
//  UnsplashAPI.swift
//  Gallery
//
//  Created by Alexander Baraley on 5/28/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//


//KeychainWrapper.standard.string(forKey: UnsplashAccessToken.key)
//KeychainWrapper.standard.removeObject(forKey: UnsplashAccessToken.key)
//KeychainWrapper.standard.set(unsplashAccessToken.token, forKey: UnsplashAccessToken.key)

import Foundation

enum UnsplashPageSize: Int {
	case small = 10
	case middle = 20
	case large = 30
}

enum UnsplashPhotoListOrder: String {
	case latest, oldest, popular
}

struct UnsplashAPI {
	
	static let accessTokenKey = "accessTokenKey"
	static let callbackUrlScheme = "galleryApp://authorization"
	static let clientID = "eaf1051cca529d4fadd399ced3d2f84c983c8f7f76085acb9363f2b50e278013"
	static let clientSecret = "7d772bcd4792a380975c329504dd841689e89a8defc465b864951c510c28c50a"
	
	static let logOutURL = URL(string: "https://unsplash.com/logout")!
	
	static var logInURL: URL {
		var urlComponents = URLComponents()
		urlComponents.scheme = "https"
		urlComponents.host = "unsplash.com"
		urlComponents.path = "/oauth/authorize"
		urlComponents.queryItems = authorizationQueryParameters
		return urlComponents.url!
	}
	
	private static var authorizationQueryParameters: [URLQueryItem] {
		let scope = "public+read_user+read_photos+read_collections+write_likes"
		
		return [
			URLQueryItem(name: UnsplashQueryParameterName.clientID, value: UnsplashAPI.clientID),
			URLQueryItem(name: UnsplashQueryParameterName.redirectURI, value: UnsplashAPI.callbackUrlScheme),
			URLQueryItem(name: UnsplashQueryParameterName.responseType, value: "code"),
			URLQueryItem(name: UnsplashQueryParameterName.scope, value: scope)
		]
	}
}

enum UnsplashQueryParameterName {
	static let page = "page"
	static let perPage = "per_page"
	static let orderedBy = "order_by"
	static let clientID = "client_id"
	static let clientSecret = "client_secret"
	static let redirectURI = "redirect_uri"
	static let code = "code"
	static let scope = "scope"
	static let responseType = "response_type"
	static let grantType = "grant_type"
	static let authorizationCode = "authorization_code"
	static let accessToken = "access_token"
}
