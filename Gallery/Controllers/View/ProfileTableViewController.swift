//
//  ProfileTableViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/5/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController, SegueHandlerType {
	
	var networkService: NetworkService!
        
    var userData: AuthenticatedUserData? {
        didSet { if isViewLoaded { userDataDidChange() } }
    }
	
	var updateUserDataAction: (() -> ())?
	var logOutAction: (() -> ())?
	
	// MARK: - Outlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
	@IBOutlet private var nickName: UILabel!
	
    @IBOutlet private var biographyLabel: UILabel!
	
	@IBOutlet private var locationLabel: UILabel!
	
	@IBOutlet private var photosRow: UITableViewCell!
	@IBOutlet private var likesRow: UITableViewCell!
	@IBOutlet private var collectionsRow: UITableViewCell!
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initialConfiguretion()
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case uploadedPhotos, likedPhotos, collections
	}
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		return SegueIdentifier(rawValue: identifier) == .likedPhotos
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
		case .likedPhotos:
			guard let accessToken = userData?.accessToken, let userName = userData?.user.userName
			else { return }
			
			let vc = segue.destination as! PhotosCollectionViewController
			
			let request = PhotoListRequest(likedPhotosOfUser: userName, accessToken: accessToken)
			
			vc.title = "Liked photos"
			vc.networkRequestPerformer = NetworkService()
			vc.photoStore = PhotoStore(networkService: NetworkService(), photoListRequest: request)
			
		default:
			break
		}
	}
	
	// MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView,
							shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		
		switch Section(rawValue: indexPath.section)! {
		case .name, .biography, .location:	return false
		case .content, .edit, .logOut:		return true
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("select \(indexPath)\n")
		
		if Section(rawValue: indexPath.section) == .logOut {
			logOutAction?()
		}
	}
}

// MARK: - Private
private extension ProfileTableViewController {
	
	enum Section: Int {
		case name, biography, location, content, edit, logOut
	}
	
	func initialConfiguretion() {
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .darkGray
		refreshControl.addTarget(self, action: #selector(updateUserData), for: .valueChanged)
		
		self.refreshControl = refreshControl
		
		if userData != nil {
			userDataDidChange()
		}
	}
	
	@objc func updateUserData() {
		updateUserDataAction?()
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
			DispatchQueue.main.async { self?.imageView.image = image }
        }
		
		photosRow.detailTextLabel?.text = String(user.totalPhotos)
		likesRow.detailTextLabel?.text = String(user.totalLikes)
		collectionsRow.detailTextLabel?.text = String(user.totalCollections)
		
		photosRow.accessoryType = user.totalPhotos > 0 ? .disclosureIndicator : .none
		likesRow.accessoryType = user.totalLikes > 0 ? .disclosureIndicator : .none
		collectionsRow.accessoryType = .none//user.totalCollections > 0 ? .disclosureIndicator : .none
		
		tableView.reloadData()
    }
}
