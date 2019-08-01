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
		
		collectionOfPhotosCollectionVC?.isRefreshable = true
		
		updateChildControllerDataSource()
	}
	
	// MARK: - Overriden
	
	override func initializeSearchResultsController() -> BaseImagesCollectionViewController? {
		let viewController = UIStoryboard.storyboard(storyboard: .collections)
			.instantiateViewController() as CollectionsOfPhotosCollectionViewController
		return viewController
	}
	
	override func setupSearchController() {
		super.setupSearchController()
		searchController.searchBar.placeholder = "Search Collections"
	}
	
	override func updateChildControllerDataSource() {
		collectionOfPhotosCollectionVC?.paginalContentStore = createPhotoCollectionStore()
	}
	
	// MARK: - AuthenticationObserver
	
	func authenticationDidStart() {
		collectionOfPhotosCollectionVC?.paginalContentStore = nil
	}
	
	// MARK: - UISearchBarDelegate
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let resultsController = searchResultsController as? CollectionsOfPhotosCollectionViewController,
			let query = searchBar.text,
			!query.isEmpty {
			
			resultsController.paginalContentStore = createPhotoCollectionStore(with: query)
		}
	}
	
	override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		super.searchBarCancelButtonClicked(searchBar)
		if let vc = searchResultsController as? CollectionsOfPhotosCollectionViewController {
			vc.paginalContentStore = nil
		}
	}
}

// MARK: - Helpers
private extension CollectionOfPhotosRootViewController {
	
	func createPhotoCollectionStore(with searchQuery: String? = nil) -> PaginalContentStore<
		PhotoCollectionListRequest, CollectionsOfPhotosCollectionViewCell
		> {
			
		let photoCollectionListRequest: PhotoCollectionListRequest
		
		if let query = searchQuery {
			photoCollectionListRequest = PhotoCollectionListRequest
				.init(searchQuery: query, pageSize: .large, accessToken: userData?.accessToken)
			
		} else if contentTypeToggler.selectedSegmentIndex == 0 {
			photoCollectionListRequest = PhotoCollectionListRequest
				.init(pageSize: .large, accessToken: userData?.accessToken)
			
		} else {
			photoCollectionListRequest = PhotoCollectionListRequest
				.init(featuredCollectionsWtithPageSize: .large, accessToken: userData?.accessToken)
		}
		
		return PaginalContentStore(networkService: NetworkService(), paginalRequest: photoCollectionListRequest)
	}
}
