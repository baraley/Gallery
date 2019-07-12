//
//  AuthenticationPerformer.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/14/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation
import AuthenticationServices
import SwiftKeychainWrapper

class AuthenticationPerformer: NSObject, AuthenticationInformer {
    
    // MARK: - Private properties
    
    private let networkService: NetworkService
	private var webAuthSession: ASWebAuthenticationSession?
    
    private(set) var state: AuthenticationState { didSet { authenticationStateDidChange() } }
    
    init(networkService: NetworkService = NetworkService()) {		
        self.networkService = networkService
        state = .unauthenticated
		super.init()
		loadUserDataIfAvailable()
    }
    
    // MARK: - AuthorizationInformer
    
    private var observations = [ObjectIdentifier : Observation]()
    
    
    func addObserve(_ observer: AuthenticationObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }
    
    func removeObserver(_ observer: AuthenticationObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}

// MARK: - Public methods
extension AuthenticationPerformer {
	
	func updateUserData() {
		loadUserDataIfAvailable()
	}
	
	func performLogIn() {
        switch state {
        case .unauthenticated, .authenticationFailed(_):
            requestAuthorizationCode()
        default:
            break
        }
	}
	
	func performLogOut() {
		if case .authenticated(_) = state {
            UIApplication.shared.open(UnsplashAPI.logOutURL) { [weak self] (success) in
                if success { self?.cleanAuthorizationData() }
            }
        }
	}
}

// MARK: - Helpers
private extension AuthenticationPerformer {
    
    struct Observation {
        weak var observer: AuthenticationObserver?
    }
    
    func authenticationStateDidChange() {
        observations.forEach { (key, observation) in
            guard let observer = observation.observer else {
                observations.removeValue(forKey: key)
                return
            }
            
            switch state {
            case .isAuthenticating:
                observer.authenticationDidStart()
            case .authenticated(let userData):
                observer.authenticationDidFinish(with: userData)
            case .unauthenticated:
                observer.deauthenticationDidFinish()
            case .authenticationFailed(let error):
                observer.authorizationDidFail(with: error)
            }
        }
    }
	
	func loadUserDataIfAvailable() {
		guard let accessToken = KeychainWrapper.standard.string(forKey: UnsplashAPI.accessTokenKey)
		else { return }
		
		loadAuthorizedUser(with: accessToken)
	}
	
	func requestAuthorizationCode() {
		let handler: ASWebAuthenticationSession.CompletionHandler = { [weak self] (callBack, error) in
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
						self.state = .authenticationFailed(error)
					}
				}
			}
		}
	}
	
	func loadAuthorizedUser(with accessToken: String) {
		state = .isAuthenticating
		
		let userRequest = UserRequest(accessToken: accessToken)
		
		networkService.performRequest(userRequest) { [weak self] (result) in
			DispatchQueue.main.async {
				
				switch result {
				case .success(let user):
					let userData = AuthenticatedUserData(accessToken: accessToken, user: user)
					self?.state = .authenticated(userData)
					
				case .failure(let error):
					if let self = self {
						self.state = .authenticationFailed(error)
					}
					self?.cleanAuthorizationData()
				}
			}
		}
	}
	
	func cleanAuthorizationData() {
		KeychainWrapper.standard.removeObject(forKey: UnsplashAPI.accessTokenKey)
		state = .unauthenticated
	}
}
