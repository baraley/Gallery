//
//  BaseImagesCollectionViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/28/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

protocol ImagesCollectionViewDataSource: UICollectionViewDataSource {
	var selectedItemIndex: Int? { get set }
	
	var contentDidStartLoadingAction: (() -> Void)? { get set }
	var newContentDidLoadAction: ((_ numberOfItems: Int, _ index: Int) -> Void)? { get set }
	var contentLoadingWasFailedAction: ((_ error: RequestError) -> Void)? { get set }
	
	func reloadContent()
	func loadMoreContent()
	
	func collectionView(_ collectionView: UICollectionView,
						loadContentForCellAt indexPath: IndexPath)
	func collectionView(_ collectionView: UICollectionView,
						cancelLoadingContentForCellAt indexPath: IndexPath)
}

class BaseImagesCollectionViewController: UICollectionViewController {
	
	// MARK: - Public properties
	
	weak var dataSource: ImagesCollectionViewDataSource? { didSet { dataSourceDidChange() } }
	
	// MARK: - Private properties
	
	private var isLoading: Bool = false { didSet { loadingStateDidChange() } }
	
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
	
	// MARK: - Overrideble
	
	func setup() {
		collectionView?.refreshControl = refreshControl
		
		let kind = UICollectionView.elementKindSectionFooter
		let identifier = CollectionViewLoadingFooter.identifier
		collectionView?.register(CollectionViewLoadingFooter.self,
								 forSupplementaryViewOfKind: kind,
								 withReuseIdentifier: identifier)
	}
	
	func dataSourceDidChange() {
		guard let dataSource = dataSource else {
			collectionView.dataSource = nil
			collectionView.reloadData()
			return
		}
		
		errorMessageWasShown = false
		
		dataSource.contentDidStartLoadingAction = contentDidStartLoading
		dataSource.newContentDidLoadAction = newContentDidLoad(numberOfItems:at:)
		dataSource.contentLoadingWasFailedAction = contentLoadingWasFailed(with:)
		
		collectionView.dataSource = dataSource
		collectionView?.reloadData()
	}
	
	func loadingStateDidChange() {
		if isLoading {
			if !refreshControl.isRefreshing {
				activityIndicatorView?.startAnimating()
			}
		} else {
			refreshControl.endRefreshing()
			activityIndicatorView?.stopAnimating()
		}
	}
	
	@objc func refreshPhotos() {
		dataSource?.reloadContent()
		collectionView.reloadData()
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

private extension BaseImagesCollectionViewController {
	
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
	
	func contentDidStartLoading() {
		isLoading = true
	}
	
	func newContentDidLoad(numberOfItems: Int, at index: Int) {
		isLoading = false
		errorMessageWasShown = false
		
		insertItems(numberOfItems, at: index)
	}
	
	func contentLoadingWasFailed(with error: RequestError) {
		isLoading = false
		handle(error)
	}
}

// MARK: - UICollectionViewDelegate
extension BaseImagesCollectionViewController {
	
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
		
		dataSource?.loadMoreContent()
	}
}
