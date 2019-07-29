//
//  BaseImagesRootViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/20/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class BaseImagesRootViewController: UIViewController {
    
    // MARK: - Public properties
	
    var authenticationInformer: AuthenticationInformer? {
        didSet {
            authenticationInformer?.addObserve(self)
        }
    }
    
    // MARK: - Private properties
	
    private(set) var userData: AuthenticatedUserData? {
		didSet { updateChildControllerDataSource() }
	}
	
	// MARK: - Outlets -
	
	@IBOutlet private(set) var contentTypeToggler: UISegmentedControl!
	
	// MARK: - Actions -
	
	@IBAction func toggleContentType(_ sender: UISegmentedControl) {
		updateChildControllerDataSource()
	}
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationController?.view.backgroundColor = .white
	}
	
	func updateChildControllerDataSource() { }
}

// MARK: - AuthenticationObserver
extension BaseImagesRootViewController: AuthenticationObserver {
    
    func authenticationDidFinish(with userData: AuthenticatedUserData) {
        self.userData = userData
    }
    
    func deauthenticationDidFinish() {
        userData = nil
    }
}
