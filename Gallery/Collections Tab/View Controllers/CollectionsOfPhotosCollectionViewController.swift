//
//  CollectionsOfPhotosCollectionViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/28/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

private let cellSizeWidthMultiplier: CGFloat = 0.9
private let cellSizeHeightMultiplier: CGFloat = 0.25

class CollectionsOfPhotosCollectionViewController: BaseImagesCollectionViewController, SegueHandlerType {
	
	// MARK: - Public properties
	
	var paginalContentStore: PaginalContentStore
		<PhotoCollectionListRequest, CollectionsOfPhotosCollectionViewCell>? {
		didSet { dataSource = paginalContentStore }
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case photosFromCollection
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard case .photosFromCollection = segueIdentifier(for: segue) else { return }
		
		guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
			let photoCollection = paginalContentStore?.itemAt(indexPath.item)
			else { return }
		
		let imagesCollectionViewController = segue.destination as! PhotosCollectionViewController
		
		let request = PhotoListRequest(photosFromCollection: photoCollection)
		
		imagesCollectionViewController.title = photoCollection.title
		imagesCollectionViewController.paginalContentStore = PaginalContentStore(
			networkService: NetworkService(), paginalRequest: request
		)
	}
	
	// MARK: - Overriden
	
	override func setup() {
		super.setup()
		
		if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
			let width = UIScreen.main.bounds.size.width * cellSizeWidthMultiplier
			let height = UIScreen.main.bounds.size.height * cellSizeHeightMultiplier
			
			layout.itemSize = CGSize(width: width, height: height)
		}
	}
}
