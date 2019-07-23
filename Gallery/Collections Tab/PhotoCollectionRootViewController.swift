//
//  PhotoCollectionRootViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/22/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotoCollectionRootViewController: UIViewController, SegueHandlerType {
	
	// MARK: - Public properties
	
	var authenticationInformer: AuthenticationInformer? {
		didSet {
			authenticationInformer?.addObserve(self)
		}
	}
	
	// MARK: - Private properties
	
	private var photoCollectionsViewController: PhotoCollectionsCollectionViewController?
	
	private var userData: AuthenticatedUserData? {
		didSet {
			photoCollectionsViewController?.photoCollectionStore = createPhotoCollectionStore()
		}
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case photoCollections
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard case .photoCollections = segueIdentifier(for: segue) else { return }
		
		photoCollectionsViewController = segue.destination as? PhotoCollectionsCollectionViewController
		
		photoCollectionsViewController?.networkRequestPerformer = NetworkService()
		if authenticationInformer?.state != .isAuthenticating {
			photoCollectionsViewController?.photoCollectionStore = createPhotoCollectionStore()
		}
	}
}

// MARK: - Helpers
private extension PhotoCollectionRootViewController {
	
	func createPhotoCollectionStore() -> PhotoCollectionStore {
		
		let photoCollectionListRequest: PhotoCollectionListRequest
		
		if let userData = userData {
			photoCollectionListRequest = .init(accessToken: userData.accessToken)
		} else {
			photoCollectionListRequest = .init()
		}
		
		return PhotoCollectionStore(networkService: NetworkService(),
									photoCollectionsListRequest: photoCollectionListRequest)
	}
}

// MARK: - AuthenticationObserver
extension PhotoCollectionRootViewController: AuthenticationObserver {
	
	func authenticationDidFinish(with userData: AuthenticatedUserData) {
		self.userData = userData
	}
	
	func authenticationDidStart() {
		photoCollectionsViewController?.photoCollectionStore = nil
	}
	
	func deauthenticationDidFinish() {
		userData = nil
	}
}
