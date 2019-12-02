//
//  UserViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/3/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class ProfileRootViewController: UIViewController, SegueHandlerType {
    
    // MARK: - Public properties
    
    var authenticationPerformer: AuthenticationPerformer? {
        didSet { authenticationPerformer?.addObserve(self) }
    }
	
    // MARK: - Private propertiesv
    
	private var profileTableViewController: ProfileTableViewController? {
		didSet { setupProfileTableViewController() }
	}
	
    // MARK: - Outlets
	
	@IBOutlet private var loadingView: UIActivityIndicatorView?
    @IBOutlet private var authorizationButton: UIButton?
	
    // MARK: - Actions
    
    @IBAction private func authorizationButtonAction(_ sender: UIButton) {
        showAuthenticationAlert()
    }
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
	}
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		authenticationStateDidChange()
	}

	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case profile, editUserData
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
		case .profile:
			profileTableViewController = segue.destination as? ProfileTableViewController
			profileTableViewController?.view.isHidden = true
			
		case .editUserData:
			let navVC = segue.destination as! UINavigationController
			let editProfileViewController = navVC.viewControllers[0] as! EditProfileTableViewController
			
			if let state = authenticationPerformer?.state, case .authenticated(let userData) = state {
				editProfileViewController.userData = EditableUserData(user: userData.user)
			}
		}
	}
	
	@IBAction private func unwindFromEditProfileController(_ segue: UIStoryboardSegue) {
		if let editProfileController = segue.source as? EditProfileTableViewController,
			let userData = editProfileController.userData {
			authenticationPerformer?.updateUserData(with: userData)
		}
	}
}

// MARK: - Private
private extension ProfileRootViewController {
	
	func setupProfileTableViewController() {
		guard let profileVC = profileTableViewController else { return }
		
		profileVC.updateUserDataAction = { [weak self] in
			self?.authenticationPerformer?.updateUserData()
		}
		profileVC.editProfileAction = { [weak self] in
			self?.performSegue(withIdentifier: .editUserData, sender: nil)
		}
		profileVC.logOutAction = { [weak self] in
			self?.authenticationPerformer?.performLogOut()
		}
	}
	
	func authenticationStateDidChange() {
		loadingView?.stopAnimating()
		profileTableViewController?.view.isHidden = true
		
		guard let state = authenticationPerformer?.state else { return }
		
		switch state {
		case .authenticated(let userData):
			authorizationButton?.isHidden = true
			profileTableViewController?.networkService = NetworkService()
			profileTableViewController?.userData = userData
			profileTableViewController?.view.isHidden = false
			
		case .unauthenticated:
			authorizationButton?.isHidden = false
			
		case .isAuthenticating:
			loadingView?.startAnimating()
			authorizationButton?.isHidden = true
			
		case .authenticationFailed(let error):
			authorizationButton?.isHidden = true
			show(error)
		}
	}
    
    func showAuthenticationAlert() {
        let message = "Login alredy in the pastboard.\nPassword(8): 11111111"
		
        let alert = UIAlertController(
            title: "Sample accaunt", message: message, preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            UIPasteboard.general.string = "dulmayarku@enayu.com"
            self.authenticationPerformer?.performLogIn()
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
        authenticationStateDidChange()
    }
    
    func authenticationDidFinish(with userData: AuthenticatedUserData) {
        authenticationStateDidChange()
    }
    
    func deauthenticationDidFinish() {
       authenticationStateDidChange()
    }
    
    func authorizationDidFail(with error: RequestError) {
		authenticationStateDidChange()
    }
}
