//
//  AuthorizationManager.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/14/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation
import SafariServices
import SwiftKeychainWrapper

extension Notification.Name {
	static let authorizationCallback = Notification.Name("AuthorizationCallback")
}

protocol AuthorizationManagerDelegate: AnyObject {
	func authorizationManager(_ manager: AuthorizationManager,
							  didChangeAuthorizationState state: AuthorizationManager.AuthorizationState)
	func authorizationManager(_ manager: AuthorizationManager,
							  didFailAuthorizationWith errorMessage: String)
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
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {		
        self.networkManager = networkManager
		super.init()
		loadUserDataIfAvailable()
    }
	
	private var userDataState: (isLoading: Bool, userData: AuthorizedUserData?) = (false, nil) {
		didSet {
			delegate?.authorizationManager(self, didChangeAuthorizationState: authorizationState)
		}
	}
    
    private var safariViewController: SFSafariViewController?
    private var isLogOutPerforming = false
}

// MARK: - Public methods
extension AuthorizationManager {
	
	func performLogIn(from presentingViewController: UIViewController) {
		NotificationCenter.default.addObserver(self, selector: #selector(parseAuthorizationCode(_:)),
											   name: .authorizationCallback, object: nil)
        safariViewController = SFSafariViewController(url: UnsplashAPI.logInURL)
        safariViewController?.delegate = self
        safariViewController?.modalPresentationStyle = .overFullScreen
		
        presentingViewController.present(safariViewController!, animated: true, completion: nil)
	}
	
	func performLogOut(from presentingViewController: UIViewController) {
		
		safariViewController = SFSafariViewController(url: UnsplashAPI.logOutURL)
		safariViewController?.delegate = self
		safariViewController?.modalPresentationStyle = .popover
		
		isLogOutPerforming = true
		
		presentingViewController.present(safariViewController!, animated: true, completion: nil)
	}
}

// MARK: - SFSafariViewControllerDelegate
extension AuthorizationManager: SFSafariViewControllerDelegate {
	
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		safariViewController = nil
	}
	
	func safariViewController(_ controller: SFSafariViewController,
							  didCompleteInitialLoad didLoadSuccessfully: Bool) {
		
		if isLogOutPerforming && didLoadSuccessfully {
            isLogOutPerforming = false
            cleanAuthorizationData()
			controller.dismiss(animated: true, completion: nil)
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
	
	@objc func parseAuthorizationCode(_ notification : Notification) {
		NotificationCenter.default.removeObserver(self, name: .authorizationCallback, object: nil)
		guard let url = notification.object as? URL else { return }
		
		let urlComponents = URLComponents(string: url.absoluteString)
		if let code = urlComponents?.queryItems?.filter({$0.name == "code"}).first?.value {
			
			requestAccessToken(with: code)
		}
		safariViewController?.dismiss(animated: true, completion: nil)
	}
	
	func requestAccessToken(with code: String) {
		let authorizationRequest = UnsplashAccessTokenRequest(authorizationCode: code)
		
		networkManager.performRequest(authorizationRequest) { [weak self] (result) in
			DispatchQueue.main.async {
				
				switch result {
				case .success(let token):
				
					KeychainWrapper.standard.set(token, forKey: UnsplashAPI.accessTokenKey)
					self?.loadAuthorizedUser(with: token)
					
				case let .failure(errorMessage):
					print(errorMessage)
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
					
				case let .failure(errorMessage):
					if let self = self {
						self.delegate?.authorizationManager( self, didFailAuthorizationWith: errorMessage)
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
