//
//  CollectionsOfPhotosFlowController.swift
//  Gallery
//
//  Created by Alexander Baraley on 22.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class CollectionsOfPhotosFlowController: UINavigationController {

	// MARK: - Initialization

	private let authenticationStateProvider: AuthenticationStateProvider

	init(authenticationStateProvider: AuthenticationStateProvider) {
		self.authenticationStateProvider = authenticationStateProvider

		super.init(nibName: nil, bundle: nil)

		navigationBar.prefersLargeTitles = true
		title = "Collections"
		tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "collections"), selectedImage: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Properties

	private lazy var searchController = UISearchController(searchResultsController: nil)
	private weak var collectionsOfPhotosViewController: CollectionsOfPhotosViewController?

	// MARK: - Segmented control

	private lazy var collectionOfPhotosTypeSegmentedControl: UISegmentedControl = {
		let control = UISegmentedControl(items: ["New", "Featured"])
		control.addTarget(self, action: #selector(segmentedControlValueDidChange), for: .valueChanged)
		control.selectedSegmentIndex = 0

		return control
	}()

	@objc func segmentedControlValueDidChange(_ segmentedControl: UISegmentedControl) {
		collectionsOfPhotosViewController?.dataSource = makeCollectionsOfPhotosModelController()
	}

	// MARK: - Life cycle

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		setupSearchController()
	}

	// MARK: - Public

	func start() {
		let controller = makeCollectionsOfPhotosViewController()
		collectionsOfPhotosViewController = controller

		setViewControllers([controller], animated: false)
	}
}

// MARK: - Private
private extension CollectionsOfPhotosFlowController {

	func makeCollectionsOfPhotosViewController() -> CollectionsOfPhotosViewController {
		let layout = CollectionsOfPhotosCollectionViewLayout()
		let collectionsOfPhotosModelController = makeCollectionsOfPhotosModelController()

		let controller = CollectionsOfPhotosViewController(
			networkService: NetworkService(),
			collectionViewLayout: layout
		)

		controller.navigationItem.title = title
		controller.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: collectionOfPhotosTypeSegmentedControl)
		controller.dataSource = collectionsOfPhotosModelController
		controller.collectionDidSelectHandler = { [weak self] (selectedCollectionIndex) in
			self?.handleSelectionOfCollection(at: selectedCollectionIndex)
		}

		return controller
	}

	func makeCollectionsOfPhotosModelController(with searchQuery: String? = nil) -> CollectionsOfPhotosModelController {

		let photoCollectionListRequest: PhotoCollectionListRequest

		if let query = searchQuery {
			photoCollectionListRequest = PhotoCollectionListRequest(
				searchQuery: query,
				accessToken: authenticationStateProvider.accessToken
			)

		} else if collectionOfPhotosTypeSegmentedControl.selectedSegmentIndex == 0 {
			photoCollectionListRequest = PhotoCollectionListRequest(
				accessToken: authenticationStateProvider.accessToken
			)

		} else {
			photoCollectionListRequest = PhotoCollectionListRequest(
				featuredCollectionsWithPageSize: .large,
				accessToken: authenticationStateProvider.accessToken
			)
		}
		return CollectionsOfPhotosModelController(
			networkService: NetworkService(),
			photoCollectionListRequest: photoCollectionListRequest
		)
	}

	func makePhotosModelController(with searchQuery: String) -> PhotosModelController {
		let request = PhotoListRequest(searchQuery: searchQuery, accessToken: authenticationStateProvider.accessToken)
		let modelController = PhotosModelController(networkService: NetworkService(), photoListRequest: request)

		return modelController
	}

	func handleSelectionOfCollection(at index: Int) {
		guard let modelController = collectionsOfPhotosViewController?.dataSource,
			let selectedCollection = modelController.collectionAt(index) else { return }

		let networkService = NetworkService()
		let request = PhotoListRequest(
			photosFromCollection: selectedCollection,
			accessToken: authenticationStateProvider.accessToken
		)
		let photosModelController = PhotosModelController(networkService: networkService, photoListRequest: request)
		let layout = TilesCollectionViewLayout()
		layout.dataSource = photosModelController

		let photosViewController = TilesPhotosViewController(
			networkService: networkService,
			authenticationStateProvider: authenticationStateProvider,
			collectionViewLayout: layout
		)

		photosViewController.title = modelController.collectionAt(index)?.title
		photosViewController.dataSource = photosModelController
		photosViewController.photoDidSelectHandler = { (selectedPhotoIndex) in
			photosModelController.selectedPhotoIndex = selectedPhotoIndex

			let fullScreenPhotosViewController = FullScreenPhotosViewController(
				networkService: networkService,
				authenticationStateProvider: self.authenticationStateProvider,
				collectionViewLayout: FullScreenPhotosCollectionViewLayout()
			)
			fullScreenPhotosViewController.dataSource = photosModelController

			self.pushViewController(fullScreenPhotosViewController, animated: true)
		}

		pushViewController(photosViewController, animated: true)
	}

	func setupSearchController() {
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchBar.placeholder = "Search Photos"
		searchController.searchBar.autocorrectionType = .yes
		searchController.searchBar.delegate = self

		definesPresentationContext = true

		collectionsOfPhotosViewController?.navigationItem.searchController = searchController
	}
}

// MARK: - PhotosTabFlowController
extension CollectionsOfPhotosFlowController: AuthenticationObserver {

	func authenticationDidFinish(with userData: AuthenticatedUserData) {
		collectionsOfPhotosViewController?.dataSource = makeCollectionsOfPhotosModelController()
	}

	func deauthenticationDidFinish() {
		collectionsOfPhotosViewController?.dataSource = makeCollectionsOfPhotosModelController()
	}
}

// MARK: - UISearchBarDelegate
extension CollectionsOfPhotosFlowController: UISearchBarDelegate {

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let searchQuery = searchBar.text, !searchQuery.isEmpty {
			collectionsOfPhotosViewController?.dataSource = makeCollectionsOfPhotosModelController(with: searchQuery)
		} else {
			searchBar.resignFirstResponder()
		}
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = ""
		searchBar.resignFirstResponder()
		collectionsOfPhotosViewController?.dataSource = makeCollectionsOfPhotosModelController()
	}
}
