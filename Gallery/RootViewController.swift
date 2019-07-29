//
//  RootViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/3/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController {
    
	private lazy var authenticationPerformer: AuthenticationPerformer = .init()
    
    private var photosRootViewController: ImagesRootViewController? {
        didSet {
            photosRootViewController?.authenticationInformer = authenticationPerformer
        }
    }
	
	private var photoCollectionsRootViewController: ImagesRootViewController? {
		didSet {
			photoCollectionsRootViewController?.authenticationInformer = authenticationPerformer
		}
	}
    
    private var profileRootViewController: ProfileRootViewController?{
        didSet {
            profileRootViewController?.authenticationPerformer = authenticationPerformer
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        selectedViewController = viewControllers?[2]
        parseViewControllers()
    }
}

// MARK: - Private
private extension RootViewController {
    
    func parseViewControllers() {
        guard let viewControllers = viewControllers else { return }
        
        let tabRootControllers: [UIViewController] = viewControllers.compactMap {
            let navVC = $0 as? UINavigationController
            return navVC?.viewControllers[0] ?? nil
        }
		photosRootViewController = tabRootControllers[0] as? ImagesRootViewController
        photoCollectionsRootViewController = tabRootControllers[1] as? ImagesRootViewController
		profileRootViewController = tabRootControllers[2] as? ProfileRootViewController
    }
}
