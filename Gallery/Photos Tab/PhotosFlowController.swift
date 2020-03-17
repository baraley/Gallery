//
//  PhotosFlowController.swift
//  Gallery
//
//  Created by Alexander Baraley on 20.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotosFlowController: TabBaseFlowController {

	// MARK: - Properties

	private weak var tilesPhotosViewController: TilesPhotosViewController?
	private weak var lastOrderedPhotosModelController: PhotosModelController?

	// MARK: - Life cycle

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		searchController.searchBar.delegate = self
		tilesPhotosViewController?.navigationItem.searchController = searchController
	}

	// MARK: - Overridden

	override var searchPlaceholder: String {
		"Search Photos"
	}

	override var segmentControlItemsTittles: [String] {
		["New", "Popular"]
	}

	override func initialSetup() {
		super.initialSetup()
		
		authenticationStateProvider.addObserve(self)

		title = "Photos"
		tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "Photos"), selectedImage: nil)
	}

	override func updateRootViewControllerDataSource(with searchQuery: String? = nil) {
		let request: PhotoListRequest

		if let searchQuery = searchQuery {
			request = PhotoListRequest(searchQuery: searchQuery, accessToken: accessToken)
		} else {
			request = PhotoListRequest(order: photosOrder, accessToken: accessToken)
		}

		let photosModelController = PhotosModelController(networkService: NetworkService(), request: request)

		lastOrderedPhotosModelController = searchQuery == nil ? photosModelController : nil

		if let layout = tilesPhotosViewController?.collectionViewLayout as? SMMosaicLayout {
			layout.dataSource = photosModelController
            layout.layoutInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
            layout.spacing = 10
		}

		tilesPhotosViewController?.dataSource = photosModelController
	}

	// MARK: - Public

	func start() {
		let viewController = makeTilesPhotosViewController()
		tilesPhotosViewController = viewController

		setViewControllers([viewController], animated: false)

		if !authenticationStateProvider.isAuthenticating {
			updateRootViewControllerDataSource()
		}
	}
}

// MARK: - Private
private extension PhotosFlowController {

	var photosOrder: UnsplashPhotoListOrder {
		rightNavigationItemSegmentedControl.selectedSegmentIndex == 0 ? .latest : .popular
	}

	var accessToken: String? {
		authenticationStateProvider.accessToken
	}

	func makeTilesPhotosViewController() -> TilesPhotosViewController {

		let controller = TilesPhotosViewController(
			networkService: NetworkService(),
			authenticationStateProvider: authenticationStateProvider,
			collectionViewLayout: SMMosaicLayout()
		)

		controller.navigationItem.title = title
		controller.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavigationItemSegmentedControl)
		controller.photoDidSelectHandler = { [weak self] (selectedPhotoIndex) in
			self?.handleSelectionOfPhoto(at: selectedPhotoIndex)
		}

		return controller
	}

	func handleSelectionOfPhoto(at index: Int) {
		guard let modelController = tilesPhotosViewController?.dataSource as? PhotosModelController else { return }

		modelController.selectedPhotoIndex = index

		let fullScreenPhotosViewController = FullScreenPhotosViewController(
			networkService: NetworkService(),
			authenticationStateProvider: authenticationStateProvider,
			collectionViewLayout: FullScreenPhotosCollectionViewLayout()
		)
		fullScreenPhotosViewController.dataSource = modelController

		pushViewController(fullScreenPhotosViewController, animated: true)
	}
}

// MARK: - AuthenticationObserver
extension PhotosFlowController: AuthenticationObserver {

	func authenticationDidFinish(with userData: AuthenticatedUserData) {
		updateRootViewControllerDataSource()
	}

	func deauthenticationDidFinish() {
		updateRootViewControllerDataSource()
	}
}

// MARK: - UISearchBarDelegate
extension PhotosFlowController {

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = ""
		searchBar.resignFirstResponder()

		if let currentModelController = tilesPhotosViewController?.dataSource as? PhotosModelController,
			currentModelController != lastOrderedPhotosModelController {
			
			updateRootViewControllerDataSource()
		}
	}
}
