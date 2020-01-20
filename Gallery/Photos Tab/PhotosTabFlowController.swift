//
//  PhotosTabFlowController.swift
//  Gallery
//
//  Created by Alexander Baraley on 20.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotosTabFlowController: UINavigationController {

	// MARK: - Initialization

	private let authenticationStateProvider: AuthenticationStateProvider

	init(authenticationStateProvider: AuthenticationStateProvider) {
		self.authenticationStateProvider = authenticationStateProvider

		super.init(nibName: nil, bundle: nil)

		navigationBar.prefersLargeTitles = true
		title = "Photos"
		tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "collections"), selectedImage: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Properties

	private lazy var searchController = UISearchController(searchResultsController: nil)
	private weak var tilesPhotosViewController: TilesPhotosViewController?

	// MARK: - Segmented control

	private lazy var photosOrderSegmentedControl: UISegmentedControl = {
		let control = UISegmentedControl(items: ["New", "Popular"])
		control.addTarget(self, action: #selector(segmentedControlValueDidChange), for: .valueChanged)
		control.selectedSegmentIndex = 0

		return control
	}()

	@objc func segmentedControlValueDidChange(_ segmentedControl: UISegmentedControl) {
		updateTilesViewControllerDataSource()
	}

	// MARK: - Public

	func start() {
		let controller = makeTilesPhotosViewController()
		tilesPhotosViewController = controller
		setupSearchController()

		setViewControllers([controller], animated: false)
	}
}

// MARK: - Private
private extension PhotosTabFlowController {

	func makeTilesPhotosViewController() -> TilesPhotosViewController {
		let layout = TilesCollectionViewLayout()
		let photosModelController = makePhotosModelController(with: .latest)

		layout.dataSource = photosModelController

		let controller = TilesPhotosViewController(
			networkService: NetworkService(),
			authenticationStateProvider: authenticationStateProvider,
			collectionViewLayout: layout
		)

		controller.navigationItem.title = title
		controller.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: photosOrderSegmentedControl)
		controller.dataSource = photosModelController
		controller.photoDidSelectHandler = { [weak self] (selectedPhotoIndex) in
			self?.handleSelectionOfPhoto(at: selectedPhotoIndex)
		}

		return controller
	}

	func makePhotosModelController(with order: UnsplashPhotoListOrder) -> PhotosModelController {
		let request = PhotoListRequest(order: order, accessToken: authenticationStateProvider.accessToken)
		let modelController = PhotosModelController(networkService: NetworkService(), photoListRequest: request)

		return modelController
	}

	func makePhotosModelController(with searchQuery: String) -> PhotosModelController {
		let request = PhotoListRequest(searchQuery: searchQuery, accessToken: authenticationStateProvider.accessToken)
		let modelController = PhotosModelController(networkService: NetworkService(), photoListRequest: request)

		return modelController
	}

	func updateTilesViewControllerDataSource(with searchQuery: String? = nil) {
		let order: UnsplashPhotoListOrder = photosOrderSegmentedControl.selectedSegmentIndex == 0 ? .latest : .popular
		let photosModelController: PhotosModelController

		if let searchQuery = searchQuery {
			photosModelController = makePhotosModelController(with: searchQuery)
		} else {
			photosModelController = makePhotosModelController(with: order)
		}

		if let layout = tilesPhotosViewController?.collectionViewLayout as? TilesCollectionViewLayout {
			layout.dataSource = photosModelController
		}

		tilesPhotosViewController?.dataSource = photosModelController
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

	func setupSearchController() {
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchBar.placeholder = "Search Photos"
		searchController.searchBar.autocorrectionType = .yes
		searchController.searchBar.delegate = self
		
		tilesPhotosViewController?.navigationItem.searchController = searchController
	}
}

// MARK: - PhotosTabFlowController
extension PhotosTabFlowController: AuthenticationObserver {

	func authenticationDidFinish(with userData: AuthenticatedUserData) {
		updateTilesViewControllerDataSource()
	}

	func deauthenticationDidFinish() {
		updateTilesViewControllerDataSource()
	}
}

// MARK: - UISearchBarDelegate
extension PhotosTabFlowController: UISearchBarDelegate {

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let text = searchBar.text, !text.isEmpty {
			updateTilesViewControllerDataSource(with: text)
		} else {
			searchBar.resignFirstResponder()
		}
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = ""
		searchBar.resignFirstResponder()
		updateTilesViewControllerDataSource()
	}
}
