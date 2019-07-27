//
//  ImagesCollectionViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/19/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

private let cellSizeWidthMultiplier: CGFloat = 0.9
private let cellSizeHeightMultiplier: CGFloat = 0.25

class ImagesCollectionViewController: UICollectionViewController, SegueHandlerType {
	
	// MARK: - Types
	
	enum ContentType {
		case photos(PhotoStore?)
		case photoCollections(PhotoCollectionStore?)
	}
	
	// MARK: - Public properties
	
	var contentType: ContentType = .photos(nil) {
		didSet {
			switch contentType {
			case .photos(let photoStore): 						dataSource = photoStore
			case .photoCollections(let photoCollectionStore):	dataSource = photoCollectionStore
			}
			dataSourceDidChange()
		}
	}
	
	// MARK: - Private properties
	
	private var dataSource: ImagesCollectionViewDataSource?
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
		
		scrollToSelectedPhoto(animated: false)
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
		case photoPage, photosFromCollection
	}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
		case .photoPage:
			guard case .photos(let dataSource) = contentType else { return }
			let photoPageViewController = segue.destination as! PhotoPageViewController
			photoPageViewController.photoStore = dataSource
			photoPageViewController.networkRequestPerformer = NetworkService()
			
		case .photosFromCollection:
			guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
				case .photoCollections(let photoCollectionsStore) = contentType,
				let dataSource = photoCollectionsStore,
				let photoCollection = dataSource.photoCollectionAt(indexPath.item)
			else { return }

			let imagesCollectionViewController = segue.destination as! ImagesCollectionViewController
			
			let request = PhotoListRequest(photosFromCollection: photoCollection)
			
			imagesCollectionViewController.title = photoCollection.title
			imagesCollectionViewController.contentType = .photos(PhotoStore(
				networkService: NetworkService(), photoListRequest: request
			))
		}
	}
}

// MARK: - Helpers
private extension ImagesCollectionViewController {
	
	func setup() {
		collectionView?.refreshControl = refreshControl
		
		let kind = UICollectionView.elementKindSectionFooter
		let identifier = CollectionViewLoadingFooter.identifier
		collectionView?.register(CollectionViewLoadingFooter.self,
								 forSupplementaryViewOfKind: kind,
								 withReuseIdentifier: identifier)
		
		if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
			let width = UIScreen.main.bounds.size.width * cellSizeWidthMultiplier
			let height = UIScreen.main.bounds.size.height * cellSizeHeightMultiplier
			
			layout.itemSize = CGSize(width: width, height: height)
		}
	}
	
	func dataSourceDidChange() {
		guard let dataSource = dataSource else {
			collectionView.dataSource = nil
			collectionView.reloadData()
			return
		}
		
		if let layout = collectionView?.collectionViewLayout as? PinterestCollectionViewLayout{
			layout.dataSource = dataSource as? PinterestCollectionViewLayoutDataSource
			layout.reset()
		}
		
		errorMessageWasShown = false
		
		dataSource.contentDidStartLoadingAction = contentDidStartLoading
		dataSource.newContentDidLoadAction = newContentDidLoad(numberOfItems:at:)
		dataSource.contentLoadingWasFailedAction = contentLoadingWasFailed(with:)
		
		collectionView.dataSource = dataSource
		collectionView?.reloadData()
	}
	
	@objc private func refreshPhotos() {
		if let layout = collectionView?.collectionViewLayout as? PinterestCollectionViewLayout {
			layout.reset()
		}
		dataSource?.reloadContent(for: collectionView)
	}
	
	func scrollToSelectedPhoto(animated: Bool) {
		if let index = dataSource?.selectedItemIndex {
			let indexPath = IndexPath(item: index, section: 0)
			collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
		}
	}
	
	func insertItems(_ numberOfItems: Int, at index: Int) {
		guard numberOfItems > 0 else { return }
		
		var indexPaths: [IndexPath] = []
		
		for i in index..<index + numberOfItems {
			indexPaths.append(IndexPath(item: i, section: 0))
		}
		collectionView?.insertItems(at: indexPaths)
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
	
	func contentDidStartLoading() {
		if !refreshControl.isRefreshing {
			activityIndicatorView?.startAnimating()
		}
	}
	
	func newContentDidLoad(numberOfItems: Int, at index: Int) {
		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()
		errorMessageWasShown = false
		
		insertItems(numberOfItems, at: index)
	}
	
	func contentLoadingWasFailed(with error: RequestError) {
		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()
		handle(error)
	}
}

// MARK: - UICollectionViewDelegate
extension ImagesCollectionViewController {
	
	override func collectionView(_ collectionView: UICollectionView,
								 willDisplay cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {
		dataSource?.collectionView(collectionView, loadContentForCellAt: indexPath)
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								 didSelectItemAt indexPath: IndexPath) {
		dataSource?.selectedItemIndex = indexPath.item
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								 didEndDisplaying cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {
		dataSource?.collectionView(collectionView, cancelLoadingContentForCellAt: indexPath)
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								 willDisplaySupplementaryView view: UICollectionReusableView,
								 forElementKind elementKind: String, at indexPath: IndexPath) {
		
		guard let footer = view as? CollectionViewLoadingFooter else { return }
		activityIndicatorView = footer.activityIndicator
		
		dataSource?.loadMoreContent(for: collectionView)
	}
}
