//
//  UnsplashAPI.swift
//  Gallery
//
//  Created by Alexander Baraley on 5/28/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation

enum UnsplashPageSize: Int {
	case small = 10
	case middle = 20
	case large = 30
}

enum UnsplashPhotoListOrder: String {
	case latest, oldest, popular
}

enum UnsplashAPI {
	
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
		let scopeValues: [UnsplashPermitionScope] = [
			.readPublicData, .readUserData, .readUserPhotos, .readUserCollections,
			.writeUserData, .writeUserLikes
		]
		
		let responseType = "code"
		let scope = scopeValues.map { $0.rawValue }.joined(separator: "+")
		
		return [
			URLQueryItem(name: UnsplashParameterName.Authentication.clientID, value: UnsplashAPI.clientID),
			URLQueryItem(name: UnsplashParameterName.Authentication.redirectURI, value: UnsplashAPI.callbackUrlScheme),
			URLQueryItem(name: UnsplashParameterName.Authentication.responseType, value: responseType),
			URLQueryItem(name: UnsplashParameterName.Authentication.scope, value: scope)
		]
	}
}

enum UnsplashParameterName {
	enum Authentication {
		static let authorizationCode = "authorization_code"
		static let accessToken = "access_token"
		static let clientID = "client_id"
		static let clientSecret = "client_secret"
		static let redirectURI = "redirect_uri"
		static let responseType = "response_type"
		static let code = "code"
		static let scope = "scope"
		static let grantType = "grant_type"
	}
	
	enum ListRequest {
		static let page = "page"
		static let perPage = "per_page"
		static let orderedBy = "order_by"
		static let query = "query"
	}
	
	enum User {
		static let userName			 = "username"
		static let firstName		 = "first_name"
		static let lastName			 = "last_name"
		static let email			 = "email"
		static let url				 = "url"	//Portfolio/personal URL.
		static let location			 = "location"
		static let bio				 = "bio"
		static let instagramUserName = "instagram_username"
	}
}

enum UnsplashPermitionScope: String {
	case readPublicData = "public"					// Default. Read public data.
	case readUserData = "read_user"					// Access user’s private data.
	case writeUserData = "write_user"				// Update the user’s profile.
	case readUserPhotos = "read_photos"				// Read private data from the user’s photos.
	case writeUserPhotos = "write_photos"			// Update photos on the user’s behalf.
	case writeUserLikes = "write_likes"				// Like or unlike a photo on the user’s behalf.
	case writeUserSubscritions = "write_followers"	// Follow or unfollow a user on the user’s behalf.
	case readUserCollections = "read_collections" 	// View a user’s private collections.
	case writeUserCollections = "write_collections"	// Create and update a user’s collections.
}

