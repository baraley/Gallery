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

    private lazy var photosTabViewController = PhotosTabViewController(
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
		let navVC = UINavigationController(rootViewController: photosTabViewController)
		navVC.navigationBar.prefersLargeTitles = true

		let segmentedControl = UISegmentedControl(items: ["New", "Popular"])
		segmentedControl
			.addTarget(self, action: #selector(photosTabSegmentedControlValueDidChange(_:)), for: .valueChanged)
		segmentedControl.selectedSegmentIndex = 0

		let navItem = UINavigationItem(title: "Photos")
		navItem.rightBarButtonItem = UIBarButtonItem(customView: segmentedControl)

		photosTabViewController.navigationItem.title = "Photos"
		photosTabViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: segmentedControl)
		photosTabViewController.tabBarItem = UITabBarItem(title: "Photos", image: #imageLiteral(resourceName: "collections"), selectedImage: nil)
		photosTabViewController.dataSource = makePhotosModelController(with: .latest)

		return navVC
	}

	@objc func photosTabSegmentedControlValueDidChange(_ segmentedControl: UISegmentedControl) {
		let order: UnsplashPhotoListOrder = segmentedControl.selectedSegmentIndex == 0 ? .latest : .popular

		photosTabViewController.dataSource = makePhotosModelController(with: order)
	}

	func makePhotosModelController(with order: UnsplashPhotoListOrder) -> PhotosModelController {
		let photoListRequest: PhotoListRequest = .init(order: order, accessToken: authenticationController.accessToken)

		let modelController = PhotosModelController(networkService: NetworkService(), photoListRequest: photoListRequest)

		return modelController
	}
}
