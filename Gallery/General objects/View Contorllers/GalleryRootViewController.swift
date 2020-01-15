//
//  GalleryRootViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/3/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class GalleryRootViewController: UITabBarController {

	// MARK: - Initialization

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Properties
    
	private lazy var authenticationController: AuthenticationController = {
		let controller = AuthenticationController()
		controller.loadUserDataIfAvailable()
		return controller
	}()

    private lazy var tilesPhotosViewController = TilesPhotosViewController(
		networkService: NetworkService(),
		collectionViewLayout: PinterestCollectionViewLayout()
	)
    
    private lazy var profileRootViewController: ProfileRootViewController = {
		let controller = UIStoryboard.init(storyboard: .main).instantiateViewController() as ProfileRootViewController
		controller.authenticationController = authenticationController
		return controller
    }()

	// MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
		
//        selectedViewController = viewControllers?[2]
        instantiateViewControllers()
    }
}

// MARK: - Private
private extension GalleryRootViewController {
    
    func instantiateViewControllers() {
		let profileTabVC = UINavigationController.init(rootViewController: profileRootViewController)
		profileTabVC.navigationBar.prefersLargeTitles = true

		let photoTabViewController = makePhotoTabViewController()

        viewControllers = [
			photoTabViewController,
			profileTabVC
		]
    }

	func makePhotoTabViewController() -> UIViewController {
		let title = "Photos"

		let navVC = UINavigationController(rootViewController: tilesPhotosViewController)
		navVC.navigationBar.prefersLargeTitles = true

		let segmentedControl = UISegmentedControl(items: ["New", "Popular"])
		segmentedControl
			.addTarget(self, action: #selector(photosTabSegmentedControlValueDidChange(_:)), for: .valueChanged)
		segmentedControl.selectedSegmentIndex = 0

		tilesPhotosViewController.navigationItem.title = title
		tilesPhotosViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: segmentedControl)
		tilesPhotosViewController.tabBarItem = UITabBarItem(title: title, image: #imageLiteral(resourceName: "collections"), selectedImage: nil)
		tilesPhotosViewController.dataSource = makePhotosModelController(with: .latest)
		tilesPhotosViewController.photoDidSelectHandler = { [weak self] (selectedPhotoIndex) in
			self?.handleSelectionsOfPhoto(at: selectedPhotoIndex)
		}

		return navVC
	}

	@objc func photosTabSegmentedControlValueDidChange(_ segmentedControl: UISegmentedControl) {
		let order: UnsplashPhotoListOrder = segmentedControl.selectedSegmentIndex == 0 ? .latest : .popular

		tilesPhotosViewController.dataSource = makePhotosModelController(with: order)
	}

	func makePhotosModelController(with order: UnsplashPhotoListOrder) -> PhotosModelController {
		let request: PhotoListRequest = .init(order: order, accessToken: authenticationController.accessToken)
		let modelController = PhotosModelController(networkService: NetworkService(), photoListRequest: request)

		return modelController
	}

	func handleSelectionsOfPhoto(at index: Int) {
		guard let modelController = tilesPhotosViewController.dataSource as? PhotosModelController else {
			return
		}

		modelController.selectedPhotoIndex = index

		let layout = FullScreenPhotosCollectionViewLayout()
		let fullScreenPhotosViewController = FullScreenPhotosViewController(
			networkService: NetworkService(),
			authenticationStateProvider: authenticationController,
			collectionViewLayout: layout
		)
		fullScreenPhotosViewController.dataSource = modelController

		tilesPhotosViewController.navigationController?.pushViewController(fullScreenPhotosViewController, animated: true)
	}
}
