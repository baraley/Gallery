//
//  ProfileTableViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/5/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

	// MARK: - Types
	enum Action {
		case updateUserData, editProfile, showLikedPhotos, logOut
	}

	// MARK: - Public properties
	
	var networkService: NetworkService!
	var actionHandlers: ((Action) -> Void)?
    var userData: AuthenticatedUserData? {
        didSet {
			if isViewLoaded {
				userDataDidChange()
			}
		}
    }
	
	// MARK: - Outlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
	@IBOutlet private var nickName: UILabel!
    @IBOutlet private var biographyLabel: UILabel!
	@IBOutlet private var locationLabel: UILabel!
	@IBOutlet private var likesRow: UITableViewCell!
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initialSetup()
	}
	
	// MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView,
							shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		
		switch Section(rawValue: indexPath.section)! {
		case .name, .biography, .location:
			return false
		case .content, .editProfile, .logOut:
			return true
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		switch Section(rawValue: indexPath.section)! {
		case .editProfile:
			actionHandlers?(.editProfile)
		case .content:
			actionHandlers?(.showLikedPhotos)
		case .logOut:
			actionHandlers?(.logOut)
		default:
			break
		}
	}
}

// MARK: - Private
private extension ProfileTableViewController {
	
	enum Section: Int {
		case name, biography, location, content, editProfile, logOut
	}
	
	func initialSetup() {
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .darkGray
		refreshControl.addTarget(self, action: #selector(updateUserData), for: .valueChanged)
		
		self.refreshControl = refreshControl
		
		userDataDidChange()
	}
	
	@objc func updateUserData() {
		actionHandlers?(.updateUserData)
	}
    
    func userDataDidChange() {
		refreshControl?.endRefreshing()
		
        guard let user = userData?.user else { return }
		
		nameLabel.text = user.name
		nickName.text = user.userName.hasPrefix("@") ? user.userName : "@\(user.userName)"
		biographyLabel.text = user.biography
		locationLabel.text = user.location
		
        networkService?.performRequest(ImageRequest(url: user.profileImageURL)) { [weak self] result in
			guard let image = try? result.get() else { return }
			DispatchQueue.main.async {
				self?.imageView.image = image
				self?.imageView.layer.cornerRadius = image.size.width / 2
				self?.tableView.reloadData()
			}
        }
		
		likesRow.detailTextLabel?.text = String(user.totalLikes)
		likesRow.accessoryType = user.totalLikes > 0 ? .disclosureIndicator : .none
		
		tableView.reloadData()
    }
}
