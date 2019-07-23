//
//  PhotoCollectionsCollectionViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/19/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

private let cellSizeWidthMultiplier: CGFloat = 0.9
private let cellSizeHeightMultiplier: CGFloat = 0.25

class PhotoCollectionsCollectionViewController: UICollectionViewController, SegueHandlerType {
	
	var photoCollectionStore: PhotoCollectionStore? { didSet { photoCollectionStoreDidChange() } }
	var networkRequestPerformer: NetworkService?
	
	// MARK: - Private properties
	
	private var errorMessageWasShown = false
	
	private weak var activityIndicatorView: UIActivityIndicatorView?
	
	private lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .darkGray
		refreshControl.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
		return refreshControl
	}()
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		scrollToSelectedPhotoCollection(animated: false)
	}
	
	override func viewWillTransition(to size: CGSize,
									 with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: { (_) in
			self.collectionViewLayout.invalidateLayout()
		})
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case photos
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard case .photos = segueIdentifier(for: segue) else { return  }

		guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
			let photoCollection = photoCollectionStore?.photoCollectionAt(indexPath.item)
		else { return }
		
		let vc = segue.destination as! PhotosCollectionViewController
		
		let request = PhotoListRequest(photosFromCollection: photoCollection)
		
		vc.title = photoCollection.title
		vc.networkRequestPerformer = NetworkService()
		vc.photoStore = PhotoStore(networkService: NetworkService(), photoListRequest: request)
	}
}

// MARK: - Helpers
private extension PhotoCollectionsCollectionViewController {
	
	func setup() {
		collectionView?.refreshControl = refreshControl
		
		if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
			let width = UIScreen.main.bounds.size.width * cellSizeWidthMultiplier
			let height = UIScreen.main.bounds.size.height * cellSizeHeightMultiplier
			
			layout.itemSize = CGSize(width: width, height: height)
		}
	}
	
	func photoCollectionStoreDidChange() {
		guard let photoCollectionStore = photoCollectionStore else { return }
		
		errorMessageWasShown = false
		photoCollectionStore.delegate = self
		collectionView?.reloadData()
	}
	
	func scrollToSelectedPhotoCollection(animated: Bool) {
		if let index = photoCollectionStore?.selectedPhotoCollectionIndex {
			let indexPath = IndexPath(item: index, section: 0)
			collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
		}
	}
	
	@objc func refreshPhotos() {
		if let layout = collectionView?.collectionViewLayout as? PinterestCollectionViewLayout {
			layout.reset()
		}
		photoCollectionStore?.reloadPhotoCollections()
		collectionView?.reloadData()
	}
	
	func insertItems(_ numberOfItems: Int, at index: Int) {
		guard numberOfItems > 0 else { return }
		
		var indexPaths: [IndexPath] = []
		
		for i in index..<index + numberOfItems {
			indexPaths.append(IndexPath(item: i, section: 0))
		}
		collectionView?.insertItems(at: indexPaths)
	}
	
	func handleThumbLoading(ofPhotoCollectionAt indexPath: IndexPath,
							with result: Result<UIImage, RequestError>) {
		switch result {
		case .success(let thumb):
			let cell = collectionView?.cellForItem(at: indexPath) as? PhotoCollectionCollectionViewCell
			cell?.imageView.image = thumb
			
		case .failure(let error):
			handle(error)
		}
	}
	
	func handle(_ error: RequestError) {
		switch error {
		case .noInternet, .limitExceeded:
			if errorMessageWasShown == false {
				errorMessageWasShown = true
				showAlertWith(error.localizedDescription)
			}
		default:
			print(error.localizedDescription)
		}
	}
}

// MARK: - UICollectionViewDataSource
extension PhotoCollectionsCollectionViewController {
	
	override func collectionView(_ collectionView: UICollectionView,
								 numberOfItemsInSection section: Int) -> Int {
		return photoCollectionStore?.numberOfPhotoCollections ?? 0
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueCell(indexPath: indexPath) as PhotoCollectionCollectionViewCell
		if let photoCollection = photoCollectionStore?.photoCollectionAt(indexPath.item) {
			cell.titleLabel.text = photoCollection.title
		}
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								 viewForSupplementaryElementOfKind kind: String,
								 at indexPath: IndexPath) -> UICollectionReusableView {
		
		let view = collectionView
			.dequeueSupplementaryView(of: kind, at: indexPath) as CollectionViewLoadingFooter
		return view
	}
}

// MARK: - UICollectionViewDelegate
extension PhotoCollectionsCollectionViewController {
	
	override func collectionView(_ collectionView: UICollectionView,
								 willDisplay cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {
		
		if let photoCollection = photoCollectionStore?.photoCollectionAt(indexPath.item) {
			
			let imageRequest = ImageRequest(url: photoCollection.thumbURL)
			
			networkRequestPerformer?.performRequest(imageRequest) { [weak self] (result) in
				DispatchQueue.main.async {
					self?.handleThumbLoading(ofPhotoCollectionAt: indexPath, with: result)
				}
			}
		}
		
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								 didSelectItemAt indexPath: IndexPath) {
		photoCollectionStore?.selectedPhotoCollectionIndex = indexPath.item
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								 didEndDisplaying cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {
		
		if let photoCollection = photoCollectionStore?.photoCollectionAt(indexPath.item) {
			let imageRequest = ImageRequest(url: photoCollection.thumbURL)
			networkRequestPerformer?.cancel(imageRequest)
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								 willDisplaySupplementaryView view: UICollectionReusableView,
								 forElementKind elementKind: String, at indexPath: IndexPath) {
		
		guard let footer = view as? CollectionViewLoadingFooter else { return }
		activityIndicatorView = footer.activityIndicator
		
		photoCollectionStore?.loadPhotoCollections()
	}
}

// MARK: - CollectionStoreDelegate
extension PhotoCollectionsCollectionViewController: CollectionStoreDelegate {
	
	func photoCollectionStoreDidStartLoading(_ store: PhotoCollectionStore) {
		if !refreshControl.isRefreshing {
			activityIndicatorView?.startAnimating()
		}
	}
	
	func photoCollectionStore(_ store: PhotoCollectionStore, didInsertPhotos numberOfPhotos: Int, at index: Int) {
		
		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()
		errorMessageWasShown = false
		
		insertItems(numberOfPhotos, at: index)
	}
	
	func photoCollectionStore(_ store: PhotoCollectionStore, loadingFailedWithError error: RequestError) {
		
		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()
		handle(error)
	}
}

