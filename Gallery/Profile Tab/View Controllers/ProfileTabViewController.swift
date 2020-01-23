//
//  UserViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/3/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class ProfileTabViewController: UIViewController, SegueHandlerType {

	// MARK: - Public properties

	var authenticationController: AuthenticationController!

	// MARK: - Private properties

	private var profileTableViewController: ProfileTableViewController?
	private weak var likedPhotosViewController: TilesPhotosViewController?
	
	// MARK: - Outlets
	
	@IBOutlet private var loadingView: UIActivityIndicatorView?
	@IBOutlet private var authorizationButton: UIButton?
	
	// MARK: - Actions

	@IBAction private func authorizationButtonAction(_ sender: UIButton) {
		showAuthenticationAlert()
	}
	
	// MARK: - Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		authenticationController.addObserve(self)
	}

	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case profile, editUserData
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
		case .profile:
			profileTableViewController = segue.destination as? ProfileTableViewController
			profileTableViewController?.networkService = NetworkService()
			profileTableViewController?.actionHandlers = handleActionOfProfileTableViewController(_:)
			
		case .editUserData:
			let navVC = segue.destination as! UINavigationController
			let editProfileViewController = navVC.viewControllers[0] as! EditProfileViewController
			
			if case .authenticated(let userData) = authenticationController.state {
				editProfileViewController.userData = EditableUserData(user: userData.user)
			}
		}
	}
	
	@IBAction private func unwindFromEditProfileController(_ segue: UIStoryboardSegue) {
		if let editProfileController = segue.source as? EditProfileViewController,
			let userData = editProfileController.userData {

			authenticationController.editCurrentUserData(with: userData)
		}
	}
}

// MARK: - Private
private extension ProfileTabViewController {
	
	func initialSetup() {
		loadingView?.stopAnimating()
		authorizationButton?.isHidden = true
		profileTableViewController?.view.isHidden = true
	}

	func showAuthenticationAlert() {
		let alert = UIAlertController(
			title: "Sample account",
			message: "Login already in the pasteboard.\nPassword(8): 11111111",
			preferredStyle: .alert
		)

		alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
			UIPasteboard.general.string = "dulmayarku@enayu.com"
			self.authenticationController.performLogIn()
		})

		present(alert, animated: true)
	}

	func handleActionOfProfileTableViewController(_ action: ProfileTableViewController.Action) {
		switch action {
		case .updateUserData: 	authenticationController.loadUserDataIfAvailable()
		case .showLikedPhotos: 	showUserLikedPhotos()
		case .editProfile: 		performSegue(withIdentifier: .editUserData, sender: nil)
		case .logOut: 			authenticationController.performLogOut()
		}
	}

	func showUserLikedPhotos() {
		guard let userData = profileTableViewController?.userData else { return }

		let request = PhotoListRequest(likedPhotosOfUser: userData.user.userName, accessToken: userData.accessToken)
		let photosModelController = PhotosModelController(networkService: NetworkService(), request: request)

		let layout = TilesCollectionViewLayout()
		layout.dataSource = photosModelController

		let photosViewController = TilesPhotosViewController(
			networkService: NetworkService(),
			authenticationStateProvider: authenticationController,
			collectionViewLayout: layout
		)

		photosViewController.title = "Liked photos"
		photosViewController.dataSource = photosModelController
		photosViewController.photoDidSelectHandler = { (selectedPhotoIndex) in
			self.handleLikedPhotoSelection(at: selectedPhotoIndex)
		}

		likedPhotosViewController = photosViewController
		
		navigationController?.pushViewController(photosViewController, animated: true)
	}

	func handleLikedPhotoSelection(at index: Int) {
		guard let photosModelController = likedPhotosViewController?.dataSource as? PhotosModelController else {
			return
		}

		photosModelController.selectedPhotoIndex = index

		let fullScreenPhotosViewController = FullScreenPhotosViewController(
			networkService: NetworkService(),
			authenticationStateProvider: authenticationController,
			collectionViewLayout: FullScreenPhotosCollectionViewLayout()
		)
		fullScreenPhotosViewController.dataSource = photosModelController

		navigationController?.pushViewController(fullScreenPhotosViewController, animated: true)
	}
}

// MARK: - AuthenticationObserver
extension ProfileTabViewController: AuthenticationObserver {

	func authenticationDidStart() {
		initialSetup()

		loadingView?.startAnimating()
	}

	func authenticationDidFinish(with userData: AuthenticatedUserData) {
		initialSetup()

		profileTableViewController?.userData = userData
		profileTableViewController?.view.isHidden = false
	}

	func deauthenticationDidFinish() {
		initialSetup()

		authorizationButton?.isHidden = false
	}

	func authorizationDidFail(with error: RequestError) {
		initialSetup()

		showError(error)
	}
}
