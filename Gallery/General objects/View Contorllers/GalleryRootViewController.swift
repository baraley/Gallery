//
//  GalleryRootViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/3/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class GalleryRootViewController: UITabBarController {
    
	private lazy var authenticationController: AuthenticationController = {
		let controller = AuthenticationController()
		controller.loadUserDataIfAvailable()
		return controller
	}()
    
    private var photosRootViewController: PhotosRootViewController? {
        didSet {
            photosRootViewController?.authenticationInformer = authenticationController
        }
    }
	
	private var photoCollectionsRootViewController: CollectionOfPhotosRootViewController? {
		didSet {
			photoCollectionsRootViewController?.authenticationInformer = authenticationController
		}
	}
    
    private var profileRootViewController: ProfileRootViewController?{
        didSet {
            profileRootViewController?.authenticationController = authenticationController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		
//        selectedViewController = viewControllers?[2]
        parseViewControllers()
    }
}

// MARK: - Private
private extension GalleryRootViewController {
    
    func parseViewControllers() {
        guard let viewControllers = viewControllers else { return }
        
        let tabRootControllers: [UIViewController] = viewControllers.compactMap {
            let navVC = $0 as? UINavigationController
            return navVC?.viewControllers[0] ?? nil
        }
		photosRootViewController = tabRootControllers[0] as? PhotosRootViewController
        photoCollectionsRootViewController = tabRootControllers[1] as? CollectionOfPhotosRootViewController
		profileRootViewController = tabRootControllers[2] as? ProfileRootViewController
    }
}
