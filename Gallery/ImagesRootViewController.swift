//
//  ImagesRootViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/20/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class ImagesRootViewController: UIViewController, SegueHandlerType {
    
    // MARK: - Public properties
	
    var authenticationInformer: AuthenticationInformer? {
        didSet {
            authenticationInformer?.addObserve(self)
        }
    }
    
    // MARK: - Private properties
	
	private var imagesCollectionViewController: ImagesCollectionViewController?
    
    private var userData: AuthenticatedUserData? {
        didSet {
			imagesCollectionViewController?.dataSource = contentType == .photos ? createPhotosStore() : createPhotoCollectionStore()
        }
    }
	
	private var contentType: ContentType = .photos
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = .white
	}
	
	// MARK: - Navigation
    
    enum SegueIdentifier: String {
        case photos, photoCollections
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		imagesCollectionViewController = segue.destination as? ImagesCollectionViewController
		
		imagesCollectionViewController?.configurator = self
		
		guard authenticationInformer?.state != .isAuthenticating else { return }
		
		switch segueIdentifier(for: segue) {
		case .photos:
			contentType = .photos
			imagesCollectionViewController?.dataSource = createPhotosStore()
		case .photoCollections:
			contentType = .photoCollections
			imagesCollectionViewController?.dataSource = createPhotoCollectionStore()
		}
	}
}

// MARK: - Helpers
private extension ImagesRootViewController {
	
	enum ContentType {
		case photos, photoCollections
	}
	
	func createPhotosStore() -> PhotoStore {
		
		let photoListRequest: PhotoListRequest
        
        if let userData = userData {
            photoListRequest = .init(accessToken: userData.accessToken)
        } else {
            photoListRequest = .init()
        }
		
		return PhotoStore(networkService: NetworkService(), photoListRequest: photoListRequest)
	}
	
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
extension ImagesRootViewController: AuthenticationObserver {
    
    func authenticationDidFinish(with userData: AuthenticatedUserData) {
        self.userData = userData
    }
    
    func authenticationDidStart() {
        imagesCollectionViewController?.dataSource = nil
    }
    
    func deauthenticationDidFinish() {
        userData = nil
    }
}

// MARK: - ChildViewControllersConfigurator
extension ImagesRootViewController: ChildViewControllersConfigurator {
	
	func config(_ photoPageViewController: PhotoPageViewController) {
		photoPageViewController.photoStore = imagesCollectionViewController?.dataSource as? PhotoStore
		photoPageViewController.networkRequestPerformer = NetworkService()
	}
	
	func config(_ imagesCollectionViewController: ImagesCollectionViewController,
				forSelectedItemAt indexPath: IndexPath) {
		
		guard let dataSource = imagesCollectionViewController.dataSource as? PhotoCollectionStore,
			let photoCollection = dataSource.photoCollectionAt(indexPath.item)
		else { return }
		
		let request = PhotoListRequest(photosFromCollection: photoCollection)
		
		imagesCollectionViewController.title = photoCollection.title
		imagesCollectionViewController.dataSource = PhotoStore(
			networkService: NetworkService(), photoListRequest: request
		)
	}
}
