//
//  PhotosCollectionViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/28/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: BaseImagesCollectionViewController, SegueHandlerType {
	
	// MARK: - Public properties
	
	var paginalContentStore: PaginalContentStore<PhotoListRequest, PhotoCollectionViewCell>? {
		didSet { dataSource = paginalContentStore }
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case photoPage
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard case .photoPage = segueIdentifier(for: segue) else { return }
		
		let photoPageViewController = segue.destination as! PhotoPageViewController
		photoPageViewController.photoPageDataSource = paginalContentStore
		photoPageViewController.networkRequestPerformer = NetworkService()
	}
	
	// MARK: - Overriden
	
	override func dataSourceDidChange() {
		if let layout = collectionView?.collectionViewLayout as? PinterestCollectionViewLayout{
			layout.dataSource = paginalContentStore
			layout.reset()
		}
		super.dataSourceDidChange()
	}
	
	override func refreshPhotos() {
		if let layout = collectionView?.collectionViewLayout as? PinterestCollectionViewLayout {
			layout.reset()
		}
		super.refreshPhotos()
	}
}
