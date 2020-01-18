//
//  EditUserRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/12/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

struct EditUserRequest: UnsplashRequest {
	
	private let editableUserData: EditableUserData
	
	init(userData: EditableUserData, accessToken: String) {
		self.accessToken = accessToken
		self.editableUserData = userData
	}
	
	// MARK: - NetworkRequest
	
	func decode(_ data: Data?, response: URLResponse?, error: Error?) -> Result<User, RequestError> {
		if let data = data, let user = try? JSONDecoder().decode(User.self, from: data) {
			return .success(user)
		}
		let error =	parseError(data, response: response, error: error)
		return .failure(error)
	}
	
	// MARK: - UnsplashRequest
	
	private(set) var accessToken: String?
	
	var method = HTTPMethod.PUT
	
	var endpoint: String = "/me"
	
	var queryItems: [URLQueryItem] {
		var items = [URLQueryItem]()
		
		items.append(URLQueryItem(name: UnsplashParameterName.User.userName,
								  value: editableUserData.userName))
		items.append(URLQueryItem(name: UnsplashParameterName.User.firstName,
								  value: editableUserData.firstName))
		
		if let lastName = editableUserData.lastName {
			items.append(URLQueryItem(name: UnsplashParameterName.User.lastName, value: lastName))
		}
		if let location = editableUserData.location {
			items.append(URLQueryItem(name: UnsplashParameterName.User.location, value: location))
		}
		if let biography = editableUserData.biography {
			items.append(URLQueryItem(name: UnsplashParameterName.User.bio, value: biography))
		}
		return items
	}
}
