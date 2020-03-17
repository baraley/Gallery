//
//  TilesPhotosViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 11.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class TilesPhotosViewController: PhotosBaseViewController, UnsplashItemsLoadingObserver, LoadingFooterPresenter {

	// MARK: - Properties

	var photoDidSelectHandler: ((Int) -> Void)?

//	private var layout: TilesCollectionViewLayout? {
//		collectionView.collectionViewLayout as? TilesCollectionViewLayout
//	}
    private var layout: SMMosaicLayout? {
        collectionView.collectionViewLayout as? SMMosaicLayout
    }
	private(set) weak var activityIndicatorView: UIActivityIndicatorView?
	lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .darkGray
		refreshControl.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
		return refreshControl
	}()

	// MARK: - Overridden

	override func initialSetup() {
		super.initialSetup()

		collectionView.showsVerticalScrollIndicator = false
		collectionView.keyboardDismissMode = .onDrag
		collectionView.refreshControl = refreshControl
		collectionView.register(RoundedImageCollectionViewCell.self)
		collectionView.register(CollectionViewLoadingFooter.self,
								forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter
		)
	}

	override func dataSourceDidChange() {
		layout?.reset()
		dataSource?.addObserve(self)

		super.dataSourceDidChange()
	}

	// MARK: - NetworkImagePresenter

	override func imageRequestForImage(at indexPath: IndexPath) -> ImageRequest? {
		guard let photo = dataSource?.photoAt(indexPath.item) else { return nil }

		return ImageRequest(url: photo.thumbURL)
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

		let cell = collectionView.dequeueCell(indexPath: indexPath) as RoundedImageCollectionViewCell
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

//        UIApplication.shared.delegate?.window??.layer.speed = 0.1

        activityIndicatorView = footer.activityIndicator

		if footer.activityIndicator.isAnimating == false {
			dataSource?.loadMorePhotos()
		}
	}
}
