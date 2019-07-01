//
//  AuthorizationPerformer.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/14/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation
import AuthenticationServices
import SwiftKeychainWrapper

protocol AuthorizationPerformerDelegate: AnyObject {
	func authorizationPerformer(_ performer: AuthorizationPerformer,
								didChangeAuthorizationState state: AuthorizationPerformer.State)
	func authorizationPerformer(_ performer: AuthorizationPerformer,
								didFailAuthorizationWith error: RequestError)
}

class AuthorizationPerformer: NSObject {
	
	// MARK: - Types
	
	enum State: Equatable {
		case authorized(AuthorizedUserData)
		case unauthorized
		case isAuthorizing
	}
    
    // MARK: - Public properties
    
    weak var delegate: AuthorizationPerformerDelegate?
	
	var state: State {
		if let userData = userDataState.userData  {
			return .authorized(userData)
		} else if userDataState.isLoading {
			return .isAuthorizing
		} else {
			return .unauthorized
		}
	}

    // MARK: - Private properties
    
    private let networkService: NetworkService
	private var webAuthSession: ASWebAuthenticationSession?
    
    init(networkService: NetworkService) {		
        self.networkService = networkService
		super.init()
		loadUserDataIfAvailable()
    }
	
	private var userDataState: (isLoading: Bool, userData: AuthorizedUserData?) = (false, nil) {
		didSet {
			delegate?.authorizationPerformer(self, didChangeAuthorizationState: state)
		}
	}
}

// MARK: - Public methods
extension AuthorizationPerformer {
	
	func performLogIn() {
		requestAuthorizationCode()
	}
	
	func performLogOut() {
		UIApplication.shared.open(UnsplashAPI.logOutURL) { [weak self] (success) in
			if success { self?.cleanAuthorizationData() }
		}
	}
}

// MARK: - Helpers
private extension AuthorizationPerformer {
	
	func loadUserDataIfAvailable() {
		guard
			let accessToken = KeychainWrapper.standard.string(forKey: UnsplashAPI.accessTokenKey)
		else { return }
		
		loadAuthorizedUser(with: accessToken)
	}
	
	func requestAuthorizationCode() {
		let handler: ASWebAuthenticationSession.CompletionHandler = {
			[weak self] (callBack:URL?, error:Error?) in
			
			guard let successURL = callBack else { return }
			
			let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
			
			if let code = queryItems?.filter({$0.name == "code"}).first?.value {
				self?.requestAccessToken(with: code)
			}
		}
		
		webAuthSession = ASWebAuthenticationSession.init(
		url: UnsplashAPI.logInURL, callbackURLScheme: nil, completionHandler: handler
		)
		
		webAuthSession?.start()
	}
	
	func requestAccessToken(with code: String) {
		let authorizationRequest = UnsplashAccessTokenRequest(authorizationCode: code)
		
		networkService.performRequest(authorizationRequest) { [weak self] (result) in
			DispatchQueue.main.async {
				
				switch result {
				case .success(let token):
				
					KeychainWrapper.standard.set(token, forKey: UnsplashAPI.accessTokenKey)
					self?.loadAuthorizedUser(with: token)
					
				case .failure(let error):
					if let self = self {
						self.delegate?.authorizationPerformer(
							self, didFailAuthorizationWith: error
						)
					}
				}
			}
		}
	}
	
	func loadAuthorizedUser(with accessToken: String) {
		userDataState = (true, nil)
		
		let userRequest = UserRequest(accessToken: accessToken)
		
		networkService.performRequest(userRequest) { [weak self] (result) in
			DispatchQueue.main.async {
				
				switch result {
				case .success(let user):
					let userData = AuthorizedUserData(accessToken: accessToken, user: user)
					self?.userDataState = (false, userData)
					
				case .failure(let error):
					if let self = self {
						self.delegate?.authorizationPerformer(self, didFailAuthorizationWith: error)
					}
					self?.cleanAuthorizationData()
				}
			}
		}
	}
	
	func cleanAuthorizationData() {
		KeychainWrapper.standard.removeObject(forKey: UnsplashAPI.accessTokenKey)
		userDataState = (false, nil)
	}
}
