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
	
	// MARK: - Overriden
	
	override func initializeSearchResultsController() -> BaseImagesCollectionViewController? {
		let viewController = UIStoryboard.storyboard(storyboard: .photos)
			.instantiateViewController() as PhotosCollectionViewController
		return viewController
	}
	
	override func setupSearchController() {
		super.setupSearchController()
		searchController.searchBar.placeholder = "Search Photos"
	}
	
	override func updateChildControllerDataSource() {
		photosCollectionVC?.paginalContentStore = createContentStore()
	}
	
	// MARK: - AuthenticationObserver
	
	func authenticationDidStart() {
		photosCollectionVC?.paginalContentStore = nil
	}
	
	// MARK: - UISearchBarDelegate
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let resultsController = searchResultsController as? PhotosCollectionViewController,
			let query = searchBar.text,
			!query.isEmpty {
			
			resultsController.paginalContentStore = createContentStore(with: query)
		}
	}
}

// MARK: - Helpers
private extension PhotosRootViewController {
	
	func createContentStore(with searchQuery: String? = nil) -> PaginalContentStore<PhotoListRequest, PhotoCollectionViewCell> {
		
		let order: UnsplashPhotoListOrder = contentTypeToggler.selectedSegmentIndex == 0
			? .latest : .popular
		
		let photoListRequest: PhotoListRequest
		
		if let query = searchQuery {
			photoListRequest = PhotoListRequest(searchQuery: query, accessToken: userData?.accessToken)
		} else {
			photoListRequest = PhotoListRequest(order: order, accessToken: userData?.accessToken)
		}
		
		return PaginalContentStore(networkService: NetworkService(), paginalRequest: photoListRequest)
	}
}
