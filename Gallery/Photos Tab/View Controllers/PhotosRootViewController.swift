//
//  PhotosRootViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/29/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotosRootViewController: BaseImagesRootViewController, SegueHandlerType {
	
	private var photosCollectionVC: PhotosCollectionViewController?
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case photos
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard case .photos = segueIdentifier(for: segue) else { return }
		photosCollectionVC = segue.destination as? PhotosCollectionViewController
		
		updateChildControllerDataSource()
	}
	
	override func updateChildControllerDataSource() {
		photosCollectionVC?.paginalContentStore = createPhotosStore()
	}
	
	func authenticationDidStart() {
		photosCollectionVC?.paginalContentStore = nil
	}
}

// MARK: - Helpers
private extension PhotosRootViewController {
	
	func createPhotosStore() -> PaginalContentStore<PhotoListRequest, PhotoCollectionViewCell> {
		
		let order: UnsplashPhotoListOrder = contentTypeToggler.selectedSegmentIndex == 0
			? .latest : .popular
		
		let photoListRequest = PhotoListRequest(order: order, accessToken: userData?.accessToken)
		
		return PaginalContentStore(networkService: NetworkService(), paginalRequest: photoListRequest)
	}
}
