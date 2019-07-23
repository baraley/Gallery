//
//  AuthenticationInformer.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/12/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

protocol AuthenticationInformer {
	
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
