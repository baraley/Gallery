//
//  TilesPhotosViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 11.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class TilesPhotosViewController: PhotosBaseViewController {

	// MARK: - Properties

	private weak var activityIndicatorView: UIActivityIndicatorView?
	private var layout: TilesCollectionViewLayout? {
		collectionView.collectionViewLayout as? TilesCollectionViewLayout
	}
	private lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .darkGray
		refreshControl.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
		return refreshControl
	}()

	// MARK: - Life cycle
	
	override func viewWillAppear(_ animated: Bool) {
		dataSourceDidChange()

		super.viewWillAppear(animated)
	}

	// MARK: - Overridden

	override func initialSetup() {
		super.initialSetup()

		collectionView.showsVerticalScrollIndicator = false
		collectionView.refreshControl = refreshControl
		collectionView.register(TileCollectionViewCell.self)
		collectionView.register(
			CollectionViewLoadingFooter.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter
		)
	}

	override func dataSourceDidChange() {
		layout?.reset()

		super.dataSourceDidChange()
	}

	// MARK: - Photos loading

	override func handlePhotosLoadingEvent(_ event: LoadingState) {
		super.handlePhotosLoadingEvent(event)

		switch event {
		case .startLoading:
			if !refreshControl.isRefreshing {
				activityIndicatorView?.startAnimating()
			}
		case .loadingDidFinish(_):
			refreshControl.endRefreshing()
			activityIndicatorView?.stopAnimating()

		case .loadingError(_):
			refreshControl.endRefreshing()
			activityIndicatorView?.stopAnimating()
		}
	}

	// MARK: - Images loading

	override var photoImageRequestKeyPath: KeyPath<Photo, URL> {
		\Photo.thumbURL
	}

	override func handleImageLoadingResult(_ result: Result<UIImage, RequestError>, forCellAt indexPath: IndexPath) {
		switch result {
		case .success(let image):
			let cell = self.collectionView.cellForItem(at: indexPath) as? TileCollectionViewCell
			cell?.imageView.image = image

		case .failure(let error):
			showError(error)
		}
	}
}

// MARK: - Private
private extension TilesPhotosViewController {

	@objc func refreshPhotos() {
		layout?.reset()
		dataSource?.reloadPhotos()
		collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDataSource
extension TilesPhotosViewController {

	override func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {

		return collectionView.dequeueCell(indexPath: indexPath) as TileCollectionViewCell
	}

	override func collectionView(
		_ collectionView: UICollectionView,
		viewForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath
	) -> UICollectionReusableView {

		let view = collectionView
			.dequeueSupplementaryView(of: kind, at: indexPath) as CollectionViewLoadingFooter
		return view
	}
}

// MARK: - UICollectionViewDelegate
extension TilesPhotosViewController {

	override func collectionView(
		_ collectionView: UICollectionView,
		didSelectItemAt indexPath: IndexPath
	) {
		photoDidSelectHandler?(indexPath.item)
	}

	override func collectionView(
		_ collectionView: UICollectionView,
		willDisplaySupplementaryView view: UICollectionReusableView,
		forElementKind elementKind: String, at indexPath: IndexPath
	) {
		guard let footer = view as? CollectionViewLoadingFooter else { return }

		activityIndicatorView = footer.activityIndicator
		dataSource?.loadMorePhotos()
	}
}
