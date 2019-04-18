//
//  UserRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 5/28/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation

struct UserRequest: UnsplashRequest {
	
	private let userName: String?
	
	init(userName: String? = nil, accessToken: String? = nil) {
		self.userName = userName
		self.accessToken = accessToken
	}
	
	// MARK: - NetworkRequest
	
    func decode(_ data: Data, response: URLResponse?) -> User? {
		let decoder = JSONDecoder()
		do {
			let user = try decoder.decode(User.self, from: data)
			return user
		} catch {
			return nil
		}
	}
	
	// MARK: - UnsplashRequest
	
	var accessToken: String?
	
	var method = HTTPMethod.GET
	
	var endpoint: String {
		if let name = userName {
			return "/users/\(name)"
		} else {
			return "/me"
		}
	}
	
	var queryItems: [URLQueryItem] = []
}
