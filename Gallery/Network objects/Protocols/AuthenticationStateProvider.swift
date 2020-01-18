//
//  AuthenticationStateProvider.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/12/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

protocol AuthenticationStateProvider {
	
	var state: AuthenticationState { get }
	
	func addObserve(_ observer: AuthenticationObserver)
	func removeObserver(_ observer: AuthenticationObserver)
}

enum AuthenticationState: Equatable {
	case authenticated(AuthenticatedUserData)
	case unauthenticated
	case isAuthenticating
	case authenticationFailed(RequestError)
}

extension AuthenticationStateProvider {

	var isAuthenticated: Bool {
		if case .authenticated(_) = state {
			return true
		} else {
			return false
		}
	}

	var accessToken: String? {
		if case .authenticated(let token) = state {
			return token.accessToken
		} else {
			return nil
		}
	}
}
