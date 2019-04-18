//
//  HomeViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/20/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
	
	// MARK: - Types
	
	enum PhotosType {
		case newPhotos, likedPhotos
	}
    
    // MARK: - Public properties
    
    var authorizationManager: AuthorizationManager! {
        didSet { authorizationManager.delegate = self }
    }
    
    // MARK: - Outlets
    
    @IBOutlet private var photoTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private var authorizationButton: UIBarButtonItem!
    
    // MARK: - Private properties
	
	private var photosCollectionViewController: PhotosCollectionViewController?
	
	private var photosType: PhotosType {
		return photoTypeSegmentedControl.selectedSegmentIndex == 0 ? .newPhotos : .likedPhotos
	}
	
    // MARK: - Actions
    
    @IBAction private func authorizationButtonAction(_ sender: UIBarButtonItem) {
        switch authorizationManager.authorizationState {
        case .authorized(_):    authorizationManager.performLogOut(from: self)
        case .unauthorized:     authorizationManager.performLogIn(from: self)
        default: break
        }
    }
    
    @IBAction private func photosTypeChangedAction(_ sender: UISegmentedControl) {
		updatePhotosStore()
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        updateNavigationBar()
		updatePhotosStore()
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard case .photosCollectionViewSegue = segueIdentifier(for: segue) else { return }
		
		photosCollectionViewController = segue.destination as? PhotosCollectionViewController
		
		photosCollectionViewController?.imageLoader = ImageLoader(networkManager: NetworkManager())
	}
}

// MARK: - Helpers
private extension HomeViewController {
	
    func updateNavigationBar() {
        switch authorizationManager.authorizationState {
		case .isAuthorizing:
			navigationItem.leftBarButtonItem = UIBarButtonItem.loadingBarButtonItem
        case let state:
			authorizationButton.title = state == .unauthorized ? "Log In" : "Log Out"
            navigationItem.leftBarButtonItem = authorizationButton
        }
		updateSegmentedControl()
    }
	
	func updateSegmentedControl() {
		switch authorizationManager.authorizationState {
		case .authorized(_):
			photoTypeSegmentedControl.setEnabled(true, forSegmentAt: 1)
		case .unauthorized, .isAuthorizing:
			photoTypeSegmentedControl.selectedSegmentIndex = 0
			photoTypeSegmentedControl.setEnabled(false, forSegmentAt: 1)
		}
	}
	
	func updatePhotosStore() {
		let state = authorizationManager.authorizationState
		
		let photoListRequest: PhotoListRequest
		
		switch (state, photosType) {
		case (.isAuthorizing, _):
			photosCollectionViewController?.photoStore = nil
			return
		case (.authorized(let userData), .newPhotos):
			photoListRequest = PhotoListRequest(accessToken: userData.accessToken)
			
		case (.authorized(let userData), .likedPhotos):
			photoListRequest = PhotoListRequest(likedPhotosOfUser: userData.user.userName,
												accessToken: userData.accessToken)
		default:
			photoListRequest = PhotoListRequest()
		}
		
		photosCollectionViewController?.photoStore = PhotoStore(networkManager: NetworkManager(),
																photoListRequest: photoListRequest)
	}
}

// MARK: - AuthorizationManagerDelegate
extension HomeViewController: AuthorizationManagerDelegate {
	
	func authorizationManager(_ manager: AuthorizationManager,
							  didChangeAuthorizationState state: AuthorizationManager.AuthorizationState) {
		updateNavigationBar()
		updatePhotosStore()
	}
    
    func authorizationManager(_ manager: AuthorizationManager, didFailAuthorizationWith errorMessage: String) {
        print(errorMessage)
    }
}

// MARK: - SegueHandlerType
extension HomeViewController: SegueHandlerType {
	enum SegueIdentifier: String {
		case photosCollectionViewSegue
	}
}
