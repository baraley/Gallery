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
	
	private var photosCollectionVC: PhotosCollectionViewController?
	private var collectionOfPhotosCollectionVC: CollectionsOfPhotosCollectionViewController?
    
    private var userData: AuthenticatedUserData? {
		didSet { updateDataSource() }
	}
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = .white
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case photos, collections
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
		case .photos:
			photosCollectionVC = segue.destination as? PhotosCollectionViewController
			
			photosCollectionVC?.paginalContentStore = createPhotosStore()
			
		case .collections:
			collectionOfPhotosCollectionVC = segue.destination as? CollectionsOfPhotosCollectionViewController
			
			collectionOfPhotosCollectionVC?.paginalContentStore = createPhotoCollectionStore()
		}
	}
}

// MARK: - Helpers
private extension ImagesRootViewController {
	
	func createPhotosStore() -> PaginalContentStore<PhotoListRequest, PhotoCollectionViewCell> {
		
		let photoListRequest: PhotoListRequest
		
		if let userData = userData {
			photoListRequest = .init(accessToken: userData.accessToken)
		} else {
			photoListRequest = .init()
		}
		
		return PaginalContentStore(networkService: NetworkService(), paginalRequest: photoListRequest)
	}
	
	func createPhotoCollectionStore() -> PaginalContentStore<PhotoCollectionListRequest, CollectionsOfPhotosCollectionViewCell> {
		
		let photoCollectionListRequest: PhotoCollectionListRequest
		
		if let userData = userData {
			photoCollectionListRequest = .init(accessToken: userData.accessToken)
		} else {
			photoCollectionListRequest = .init()
		}
		
		return PaginalContentStore(networkService: NetworkService(), paginalRequest: photoCollectionListRequest)
	}
	
	func updateDataSource() {
		photosCollectionVC?.paginalContentStore = createPhotosStore()
		collectionOfPhotosCollectionVC?.paginalContentStore = createPhotoCollectionStore()
	}
}

// MARK: - AuthenticationObserver
extension ImagesRootViewController: AuthenticationObserver {
    
    func authenticationDidFinish(with userData: AuthenticatedUserData) {
        self.userData = userData
    }
    
    func authenticationDidStart() {
		photosCollectionVC?.paginalContentStore = nil
		collectionOfPhotosCollectionVC?.paginalContentStore = nil
    }
    
    func deauthenticationDidFinish() {
        userData = nil
    }
}
