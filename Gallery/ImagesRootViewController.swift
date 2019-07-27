//
//  ImagesRootViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/20/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class ImagesRootViewController: UIViewController {
    
    // MARK: - Public properties
	
	var contentType: ImagesCollectionViewController.ContentType!
	
    var authenticationInformer: AuthenticationInformer? {
        didSet {
            authenticationInformer?.addObserve(self)
        }
    }
    
    // MARK: - Private properties
	
	private var imagesCollectionViewController: ImagesCollectionViewController?
    
    private var userData: AuthenticatedUserData? {
		didSet { updateDataSource() }
	}
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = .white
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		imagesCollectionViewController = segue.destination as? ImagesCollectionViewController
		updateDataSource()
	}
}

// MARK: - Helpers
private extension ImagesRootViewController {
	
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
	
	func updateDataSource() {
		switch contentType! {
		case .photos(_):
			let dataSource = createPhotosStore()
			imagesCollectionViewController?.contentType = .photos(dataSource)
			
		case .photoCollections(_):
			let dataSource = createPhotoCollectionStore()
			imagesCollectionViewController?.contentType = .photoCollections(dataSource)
		}
	}
}

// MARK: - AuthenticationObserver
extension ImagesRootViewController: AuthenticationObserver {
    
    func authenticationDidFinish(with userData: AuthenticatedUserData) {
        self.userData = userData
    }
    
    func authenticationDidStart() {
		switch contentType! {
		case .photos(_):
			imagesCollectionViewController?.contentType = .photos(nil)
			
		case .photoCollections(_):
			imagesCollectionViewController?.contentType = .photoCollections(nil)
		}
    }
    
    func deauthenticationDidFinish() {
        userData = nil
    }
}
