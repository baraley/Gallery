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
    
    private var photosRootViewController: PhotosRootViewController? {
        didSet {
            photosRootViewController?.authenticationInformer = authenticationPerformer
        }
    }
    
    private var profileRootViewController: ProfileRootViewController?{
        didSet {
            profileRootViewController?.authenticationPerformer = authenticationPerformer
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedViewController = viewControllers?[1]
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
        
        tabRootControllers.forEach({
            if let photosRootVC = $0 as? PhotosRootViewController {
                photosRootViewController = photosRootVC
                
            } else if let profileRootVC = $0 as? ProfileRootViewController {
                profileRootViewController = profileRootVC
            }
        })
    }
}
