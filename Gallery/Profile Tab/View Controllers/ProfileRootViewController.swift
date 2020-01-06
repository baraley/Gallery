//
//  UserViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/3/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class ProfileRootViewController: UIViewController, SegueHandlerType {

	typealias ProfileActions = ProfileTableViewController.ActionsHandlers

	// MARK: - Public properties

	var authenticationController: AuthenticationController?
	
	// MARK: - Private properties

	private var profileTableViewController: ProfileTableViewController?

	private lazy var profileActions = ProfileActions.init(
		updateUserData: { [weak self] in
			self?.authenticationController?.loadUserDataIfAvailable()
		}, editProfile: { [weak self] in
			self?.performSegue(withIdentifier: .editUserData, sender: nil)
		}, logOut: { [weak self] in
			self?.authenticationController?.performLogOut()
		}
	)
	
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

		authenticationController?.addObserve(self)
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
			profileTableViewController?.actionHandlers = profileActions
			
		case .editUserData:
			let navVC = segue.destination as! UINavigationController
			let editProfileViewController = navVC.viewControllers[0] as! EditProfileTableViewController
			
			if let state = authenticationController?.state, case .authenticated(let userData) = state {
				editProfileViewController.userData = EditableUserData(user: userData.user)
			}
		}
	}
	
	@IBAction private func unwindFromEditProfileController(_ segue: UIStoryboardSegue) {
		if let editProfileController = segue.source as? EditProfileTableViewController,
			let userData = editProfileController.userData {

			authenticationController?.editCurrentUserData(with: userData)
		}
	}
}

// MARK: - Private
private extension ProfileRootViewController {
	
	func initialConfiguration() {
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
			self.authenticationController?.performLogIn()
		})

		present(alert, animated: true)
	}
	
	func show(_ error: RequestError) {
		switch error {
		case .noInternet, .limitExceeded:
			showAlertWith(error.localizedDescription)
		default:
			print(error.localizedDescription)
		}
	}
}

// MARK: - AuthenticationObserver
extension ProfileRootViewController: AuthenticationObserver {

	func authenticationDidStart() {
		initialConfiguration()

		loadingView?.startAnimating()
	}

	func authenticationDidFinish(with userData: AuthenticatedUserData) {
		initialConfiguration()

		profileTableViewController?.userData = userData
		profileTableViewController?.view.isHidden = false
	}

	func deauthenticationDidFinish() {
		initialConfiguration()

		authorizationButton?.isHidden = false
	}

	func authorizationDidFail(with error: RequestError) {
		initialConfiguration()

		show(error)
	}
}
