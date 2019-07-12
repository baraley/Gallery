//
//  AuthenticationObserver.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/12/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

protocol AuthenticationObserver: AnyObject {
	func authenticationDidStart()
	func authenticationDidFinish(with userData: AuthenticatedUserData)
	func deauthenticationDidFinish()
	func userDataDidUpdate()
	func authorizationDidFail(with error: RequestError)
}

extension AuthenticationObserver {
	func authenticationDidStart() {}
	func authenticationDidFinish(with userData: AuthenticatedUserData) {}
	func deauthenticationDidFinish() {}
	func userDataDidUpdate() {}
	func authorizationDidFail(with error: RequestError) {}
}
