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

	// MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
		
        instantiateViewControllers()
		view.backgroundColor = .white
    }

//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//
//		selectedViewController = viewControllers?[1]
//	}
}

// MARK: - Private
private extension GalleryRootViewController {
    
    func instantiateViewControllers() {
		let profileNavController = UIStoryboard.init(storyboard: .profileTab)
			.instantiateViewController() as UINavigationController

		if let profileTabVC = profileNavController.viewControllers.first as? ProfileTabViewController {
			profileTabVC.authenticationController = authenticationController
		}

		let photoTabFlowController = PhotosTabFlowController(authenticationStateProvider: authenticationController)
		photoTabFlowController.start()
		
        viewControllers = [
			photoTabFlowController,
			profileNavController
		]
    }
}
