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

		view.backgroundColor = .white
    }
}

// MARK: - Private
private extension GalleryRootViewController {
    
    func instantiateViewControllers() {
		let profileTabVC = UINavigationController.init(rootViewController: profileRootViewController)
		profileTabVC.navigationBar.prefersLargeTitles = true

		let photoTabFlowController = PhotosTabFlowController(authenticationStateProvider: authenticationController)
		photoTabFlowController.start()
		
        viewControllers = [
			photoTabFlowController,
			profileTabVC
		]
    }
}
