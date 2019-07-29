//
//  CollectionOfPhotosRootViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/29/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class CollectionOfPhotosRootViewController: BaseImagesRootViewController, SegueHandlerType {
	
	private var collectionOfPhotosCollectionVC: CollectionsOfPhotosCollectionViewController?
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case collections
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard case .collections = segueIdentifier(for: segue) else { return }
		
		collectionOfPhotosCollectionVC = segue.destination as? CollectionsOfPhotosCollectionViewController
		
		updateChildControllerDataSource()
	}
	
	override func updateChildControllerDataSource() {
		collectionOfPhotosCollectionVC?.paginalContentStore = createPhotoCollectionStore()
	}
	
	func authenticationDidStart() {
		collectionOfPhotosCollectionVC?.paginalContentStore = nil
	}
}

// MARK: - Helpers
private extension CollectionOfPhotosRootViewController {
	
	func createPhotoCollectionStore() -> PaginalContentStore<PhotoCollectionListRequest, CollectionsOfPhotosCollectionViewCell> {
		
		let photoCollectionListRequest: PhotoCollectionListRequest
		
		if contentTypeToggler.selectedSegmentIndex == 0 {
			photoCollectionListRequest = .init(pageSize: .large,
											   accessToken: userData?.accessToken)
		} else {
			photoCollectionListRequest = .init(featuredCollectionsWtithPageSize: .large,
											   accessToken: userData?.accessToken)
		}
		
		return PaginalContentStore(networkService: NetworkService(), paginalRequest: photoCollectionListRequest)
	}
}
