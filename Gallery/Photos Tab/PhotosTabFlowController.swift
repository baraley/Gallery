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

	private lazy var photosOrderSegmentedControl: UISegmentedControl = {
		let control = UISegmentedControl(items: ["New", "Popular"])
		control.addTarget(self, action: #selector(segmentedControlValueDidChange), for: .valueChanged)
		control.selectedSegmentIndex = 0

		return control
	}()

	private weak var tilesPhotosViewController: TilesPhotosViewController?

	// MARK: - Public

	func start() {
		let controller = makeTilesPhotosViewController()
		tilesPhotosViewController = controller

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
		let request: PhotoListRequest = .init(order: order, accessToken: authenticationStateProvider.accessToken)
		let modelController = PhotosModelController(networkService: NetworkService(), photoListRequest: request)

		return modelController
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

	@objc func segmentedControlValueDidChange(_ segmentedControl: UISegmentedControl) {
		updateTilesViewControllerDataSource()
	}

	func updateTilesViewControllerDataSource() {
		let order: UnsplashPhotoListOrder = photosOrderSegmentedControl.selectedSegmentIndex == 0 ? .latest : .popular
		let photosModelController = makePhotosModelController(with: order)

		if let layout = tilesPhotosViewController?.collectionViewLayout as? TilesCollectionViewLayout {
			layout.dataSource = photosModelController
		}

		tilesPhotosViewController?.dataSource = photosModelController
	}
}

extension PhotosTabFlowController: AuthenticationObserver {

	func authenticationDidFinish(with userData: AuthenticatedUserData) {
		updateTilesViewControllerDataSource()
	}

	func deauthenticationDidFinish() {
		updateTilesViewControllerDataSource()
	}
}
