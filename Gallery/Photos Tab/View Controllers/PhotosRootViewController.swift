//
//  PhotosRootViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/20/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotosRootViewController: UIViewController, SegueHandlerType {
	
	// MARK: - Types
	
	enum PhotosType {
		case newPhotos, likedPhotos
	}
    
    // MARK: - Public properties
    
    var authenticationInformer: AuthenticationInformer? {
        didSet {
            authenticationInformer?.addObserve(self)
        }
    }
    
    // MARK: - Private properties
	
	private var photosCollectionViewController: PhotosCollectionViewController?
    
    private var userData: AuthenticatedUserData? {
        didSet {
            photosCollectionViewController?.photoStore = createPhotosStore()
        }
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = .white
	}
	
	// MARK: - Navigation
    
    enum SegueIdentifier: String {
        case photosCollectionViewSegue
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard case .photosCollectionViewSegue = segueIdentifier(for: segue) else { return }
		
		photosCollectionViewController = segue.destination as? PhotosCollectionViewController
		
		photosCollectionViewController?.networkRequestPerformer = NetworkService()
		if authenticationInformer?.state != .isAuthenticating {
			photosCollectionViewController?.photoStore = createPhotosStore()
		}
	}
}

// MARK: - Helpers
private extension PhotosRootViewController {
	
	func createPhotosStore() -> PhotoStore {
		
		let photoListRequest: PhotoListRequest
        
        if let userData = userData {
            photoListRequest = .init(accessToken: userData.accessToken)
        } else {
            photoListRequest = .init()
        }
		
		return PhotoStore(networkService: NetworkService(), photoListRequest: photoListRequest)
	}
}

// MARK: - AuthenticationObserver
extension PhotosRootViewController: AuthenticationObserver {
    
    func authenticationDidFinish(with userData: AuthenticatedUserData) {
        self.userData = userData
    }
    
    func authenticationDidStart() {
        photosCollectionViewController?.photoStore = nil
    }
    
    func deauthenticationDidFinish() {
        userData = nil
    }
}
