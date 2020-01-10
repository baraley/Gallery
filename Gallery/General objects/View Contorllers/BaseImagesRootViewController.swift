//
//  BaseImagesRootViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/20/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class BaseImagesRootViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Public properties
	
    var authenticationStateProvider: AuthenticationStateProvider? {
        didSet {
            authenticationStateProvider?.addObserve(self)
        }
    }
	
	private(set) lazy var searchController = UISearchController(searchResultsController: nil)
	
	lazy var searchResultsController = initializeSearchResultsController()
	
    // MARK: - Private properties
	
    private(set) var userData: AuthenticatedUserData? {
		didSet { updateChildControllerDataSource() }
	}
	
	// MARK: - Outlets -
	
	@IBOutlet private(set) var contentTypeToggle: UISegmentedControl!
	
	// MARK: - Actions -
	
	@IBAction func toggleContentType(_ sender: UISegmentedControl) {
		updateChildControllerDataSource()
	}
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		definesPresentationContext = true
		navigationController?.view.backgroundColor = .white
		setupSearchController()
	}
	
	func updateChildControllerDataSource() { }
	
	func initializeSearchResultsController() -> BaseImagesCollectionViewController? {
		return nil
	}
	
	func setupSearchController() {
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchBar.autocorrectionType = .yes
		
		searchController.searchBar.delegate = self
		
		configureSearchResultsController()
		
		navigationItem.searchController = searchController
	}
	
	func configureSearchResultsController() {
		searchResultsController?.collectionView.refreshControl = nil
		searchResultsController?.collectionView.keyboardDismissMode = .onDrag
	}
	
	// MARK: - UISearchBarDelegate
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		if let vc = searchResultsController {
			add(vc)
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchResultsController?.remove()
	}
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
