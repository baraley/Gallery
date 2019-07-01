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
    
    private lazy var authorizationPerformer = AuthorizationPerformer(
		networkService: NetworkService(session: URLSession.shared)
	)
    
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
        switch authorizationPerformer.state {
        case .authorized(_):    authorizationPerformer.performLogOut()
        case .unauthorized:     showAuthorizationAlert()
        default: break
        }
    }
    
    @IBAction private func photosTypeChangedAction(_ sender: UISegmentedControl) {
		updatePhotosStore()
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		authorizationPerformer.delegate = self
		
        updateNavigationBar()
		updatePhotosStore()
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard case .photosCollectionViewSegue = segueIdentifier(for: segue) else { return }
		
		photosCollectionViewController = segue.destination as? PhotosCollectionViewController
		
		photosCollectionViewController?.networkRequestPerformer = NetworkService()
	}
}

// MARK: - Helpers
private extension HomeViewController {
	
    func updateNavigationBar() {
        switch authorizationPerformer.state {
		case .isAuthorizing:
			navigationItem.leftBarButtonItem = UIBarButtonItem.loadingBarButtonItem
        case let state:
			authorizationButton.title = state == .unauthorized ? "Log In" : "Log Out"
            navigationItem.leftBarButtonItem = authorizationButton
        }
		updateSegmentedControl()
    }
	
	func updateSegmentedControl() {
		switch authorizationPerformer.state {
		case .authorized(_):
			photoTypeSegmentedControl.setEnabled(true, forSegmentAt: 1)
		case .unauthorized, .isAuthorizing:
			photoTypeSegmentedControl.selectedSegmentIndex = 0
			photoTypeSegmentedControl.setEnabled(false, forSegmentAt: 1)
		}
	}
	
	func updatePhotosStore() {
		let state = authorizationPerformer.state
		
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
		
		photosCollectionViewController?.photoStore = PhotoStore(
			networkService: NetworkService(), photoListRequest: photoListRequest
		)
	}
	
	func showAuthorizationAlert() {
		let message = """
Login alredy in the pastboard.
Password(8): 	11111111
"""
		let alert = UIAlertController(
			title: "Sample accaunt", message: message, preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
			UIPasteboard.general.string = "jimlikokno@desoz.com"
			self.authorizationPerformer.performLogIn()
		})
		
		present(alert, animated: true)
	}
}

// MARK: - authorizationPerformerDelegate
extension HomeViewController: AuthorizationPerformerDelegate {
	
	func authorizationPerformer(_ performer: AuthorizationPerformer,
								didChangeAuthorizationState state: AuthorizationPerformer.State) {
		updateNavigationBar()
		updatePhotosStore()
	}
    
    func authorizationPerformer(_ performer: AuthorizationPerformer,
								didFailAuthorizationWith error: RequestError) {
		switch error {
		case .noInternet, .limitExceeded:
			showAlertWith(error.localizedDescription)
		default:
			print(error.localizedDescription)
		}
    }
}

// MARK: - SegueHandlerType
extension HomeViewController: SegueHandlerType {
	enum SegueIdentifier: String {
		case photosCollectionViewSegue
	}
}
