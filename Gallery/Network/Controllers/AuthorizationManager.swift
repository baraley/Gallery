//
//  AuthorizationManager.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/14/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation
import AuthenticationServices
import SwiftKeychainWrapper

extension Notification.Name {
	static let authorizationCallback = Notification.Name("AuthorizationCallback")
}

protocol AuthorizationManagerDelegate: AnyObject {
	func authorizationManager(_ manager: AuthorizationManager,
							  didChangeAuthorizationState state: AuthorizationManager.AuthorizationState)
	func authorizationManager(_ manager: AuthorizationManager,
							  didFailAuthorizationWith error: RequestError)
}

class AuthorizationManager: NSObject {
	
	// MARK: - Types
	
	enum AuthorizationState: Equatable {
		case authorized(AuthorizedUserData)
		case unauthorized
		case isAuthorizing
	}
    
    // MARK: - Public properties
    
    weak var delegate: AuthorizationManagerDelegate?
	
	var authorizationState: AuthorizationState {
		if let userData = userDataState.userData  {
			return .authorized(userData)
		} else if userDataState.isLoading {
			return .isAuthorizing
		} else {
			return .unauthorized
		}
	}

    // MARK: - Private properties
    
    private let networkManager: NetworkRequestPerformer
    
    init(networkManager: NetworkRequestPerformer) {		
        self.networkManager = networkManager
		super.init()
		loadUserDataIfAvailable()
    }
	
	private var userDataState: (isLoading: Bool, userData: AuthorizedUserData?) = (false, nil) {
		didSet {
			delegate?.authorizationManager(self, didChangeAuthorizationState: authorizationState)
		}
	}
	
	private var webAuthSession: ASWebAuthenticationSession?
    private var isLogOutPerforming = false
}

// MARK: - Public methods
extension AuthorizationManager {
	
	func performLogIn(from presentingViewController: UIViewController) {		
		requestAuthorizationCode()
	}
	
	func performLogOut(from presentingViewController: UIViewController) {
		UIApplication.shared.open(UnsplashAPI.logOutURL) { [weak self] (success) in
			if success { self?.cleanAuthorizationData() }
		}
	}
}

// MARK: - Helpers
private extension AuthorizationManager {
	
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
		
		networkManager.performRequest(authorizationRequest) { [weak self] (result) in
			DispatchQueue.main.async {
				
				switch result {
				case .success(let token):
				
					KeychainWrapper.standard.set(token, forKey: UnsplashAPI.accessTokenKey)
					self?.loadAuthorizedUser(with: token)
					
				case let .failure(error):
					if let self = self {
						self.delegate?.authorizationManager(
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
		
		networkManager.performRequest(userRequest) { [weak self] (result) in
			DispatchQueue.main.async {
				
				switch result {
				case .success(let user):
					
					let userData = AuthorizedUserData(accessToken: accessToken, user: user)
					self?.userDataState = (false, userData)
					
				case let .failure(error):
					if let self = self {
						self.delegate?.authorizationManager(
							self, didFailAuthorizationWith: error
						)
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
