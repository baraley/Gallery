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

	// MARK: - Overridden

	override func initialSetup() {
		super.initialSetup()

		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.keyboardDismissMode = .onDrag
		collectionView.refreshControl = refreshControl
		collectionView.register(ImageCollectionViewCell.self)
		collectionView.register(CollectionViewLoadingFooter.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter
		)
	}

	override func dataSourceDidChange() {
		layout?.reset()

		super.dataSourceDidChange()
	}

	// MARK: - Photos loading

	override func itemsLoadingDidStart() {
		super.itemsLoadingDidStart()

		if !refreshControl.isRefreshing {
			activityIndicatorView?.startAnimating()
		}
	}

	override func itemsLoadingDidFinish(numberOfItems number: Int, locationIndex index: Int) {
		super.itemsLoadingDidFinish(numberOfItems: number, locationIndex: index)

		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()
	}

	override func itemsLoadingDidFinishWith(_ error: RequestError) {
		super.itemsLoadingDidFinishWith(error)

		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()
	}

	// MARK: - Images loading

	override var photoImageRequestKeyPath: KeyPath<Photo, URL> {
		\Photo.thumbURL
	}

	override func handleImageLoadingResult(_ result: Result<UIImage, RequestError>, forCellAt indexPath: IndexPath) {
		switch result {
		case .success(let image):
			let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
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

		let cell = collectionView.dequeueCell(indexPath: indexPath) as ImageCollectionViewCell
		cell.cornerRadius = 10

		return cell
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
