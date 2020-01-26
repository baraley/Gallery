//
//  CollectionsOfPhotosFlowController.swift
//  Gallery
//
//  Created by Alexander Baraley on 22.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class CollectionsOfPhotosFlowController: TabBaseFlowController {

	// MARK: - Properties

	private weak var collectionsOfPhotosViewController: CollectionsOfPhotosViewController?
	private weak var lastCollectionOfPhotosModelController: CollectionsOfPhotosModelController?

	// MARK: - Life cycle

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		searchController.searchBar.delegate = self
		collectionsOfPhotosViewController?.navigationItem.searchController = searchController
	}

	// MARK: - Overridden

	override var searchPlaceholder: String {
		"Search Collections"
	}

	override var segmentControlItemsTittles: [String] {
		["New", "Featured"]
	}

	override func initialSetup() {
		super.initialSetup()

		authenticationStateProvider.addObserve(self)

		title = "Collections"
		tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "collections"), selectedImage: nil)
	}

	override func updateRootViewControllerDataSource(with searchQuery: String? = nil) {
		let request: PhotoCollectionListRequest

		if let query = searchQuery {
			request = PhotoCollectionListRequest(searchQuery: query, accessToken: accessToken)

		} else if rightNavigationItemSegmentedControl.selectedSegmentIndex == 0 {
			request = PhotoCollectionListRequest(accessToken: accessToken)

		} else {
			request = PhotoCollectionListRequest( featuredCollectionsWithPageSize: .large, accessToken: accessToken)
		}

		collectionsOfPhotosViewController?
			.dataSource = CollectionsOfPhotosModelController(networkService: NetworkService(), request: request)
	}

	// MARK: - Public

	func start() {
		let viewController = makeCollectionsOfPhotosViewController()
		collectionsOfPhotosViewController = viewController

		setViewControllers([viewController], animated: false)
		
		if !authenticationStateProvider.isAuthenticating {
			updateRootViewControllerDataSource()
		}
	}
}

// MARK: - Private
private extension CollectionsOfPhotosFlowController {

	var accessToken: String? {
		authenticationStateProvider.accessToken
	}

	func makeCollectionsOfPhotosViewController() -> CollectionsOfPhotosViewController {

		let controller = CollectionsOfPhotosViewController(
			networkService: NetworkService(),
			collectionViewLayout: CollectionsOfPhotosCollectionViewLayout()
		)

		controller.navigationItem.title = title
		controller.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavigationItemSegmentedControl)
		controller.collectionDidSelectHandler = { [weak self] (selectedCollectionIndex) in
			self?.handleSelectionOfCollection(at: selectedCollectionIndex)
		}

		return controller
	}

	func handleSelectionOfCollection(at index: Int) {
		guard let modelController = collectionsOfPhotosViewController?.dataSource,
			let selectedCollection = modelController.collectionAt(index) else {
				return
		}

		let accessToken = authenticationStateProvider.accessToken
		let request = PhotoListRequest(photosFromCollection: selectedCollection, accessToken: accessToken)
		let photosModelController = PhotosModelController(networkService: NetworkService(), request: request)
		let layout = TilesCollectionViewLayout()
		layout.dataSource = photosModelController

		let photosViewController = TilesPhotosViewController(
			networkService: NetworkService(),
			authenticationStateProvider: authenticationStateProvider,
			collectionViewLayout: layout
		)

		photosViewController.title = modelController.collectionAt(index)?.title
		photosViewController.dataSource = photosModelController
		photosViewController.photoDidSelectHandler = { (selectedPhotoIndex) in
			photosModelController.selectedPhotoIndex = selectedPhotoIndex

			let fullScreenPhotosViewController = FullScreenPhotosViewController(
				networkService: NetworkService(),
				authenticationStateProvider: self.authenticationStateProvider,
				collectionViewLayout: FullScreenPhotosCollectionViewLayout()
			)
			fullScreenPhotosViewController.dataSource = photosModelController

			self.pushViewController(fullScreenPhotosViewController, animated: true)
		}

		pushViewController(photosViewController, animated: true)
	}
}

// MARK: - AuthenticationObserver
extension CollectionsOfPhotosFlowController: AuthenticationObserver {

	func authenticationDidFinish(with userData: AuthenticatedUserData) {
		updateRootViewControllerDataSource()
	}

	func deauthenticationDidFinish() {
		updateRootViewControllerDataSource()
	}
}

// MARK: - UISearchBarDelegate
extension CollectionsOfPhotosFlowController {

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = ""
		searchBar.resignFirstResponder()

		let dataSource = collectionsOfPhotosViewController?.dataSource

		if let currentModelController = dataSource as? CollectionsOfPhotosModelController,
			currentModelController != lastCollectionOfPhotosModelController {

			updateRootViewControllerDataSource()
		}
	}
}
