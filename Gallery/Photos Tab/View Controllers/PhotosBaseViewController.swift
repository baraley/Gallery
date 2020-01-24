//
//  PhotosBaseViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 19.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//


import UIKit

class PhotosBaseViewController: UICollectionViewController, NetworkImagePresenter {

	// MARK: - Initialization

	let networkService: NetworkService
	let authenticationStateProvider: AuthenticationStateProvider

	init(
		networkService: NetworkService,
		authenticationStateProvider: AuthenticationStateProvider,
		collectionViewLayout layout: UICollectionViewLayout
	) {
		self.networkService = networkService
		self.authenticationStateProvider = authenticationStateProvider

		super.init(collectionViewLayout: layout)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Properties

	var dataSource: PhotosDataSource? { didSet { dataSourceDidChange() } }

	// MARK: - Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		initialSetup()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		scrollToSelectedPhoto(animated: false)
	}

	// MARK: - Setup

	func initialSetup() {

		collectionView.backgroundColor = .white
		collectionView.showsHorizontalScrollIndicator = false
	}

	// MARK: - NetworkImagePresenter

	typealias CellType = ImageCollectionViewCell

	func imageRequestForImage(at indexPath: IndexPath) -> ImageRequest? {
		nil
	}

	// MARK: - Helpers

	func scrollToSelectedPhoto(animated: Bool) {
		if let index = dataSource?.selectedPhotoIndex {
			let indexPath = IndexPath(item: index, section: 0)

			let isPortraitScrollDirection = collectionView.contentSize.width < collectionView.contentSize.height
			let scrollPosition: UICollectionView.ScrollPosition = isPortraitScrollDirection ?
				.centeredVertically : .centeredHorizontally
			collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
		}
	}

	func dataSourceDidChange() {
		collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDataSource
extension PhotosBaseViewController {

	override func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
		return dataSource?.numberOfPhotos ?? 0
	}
}

// MARK: - UICollectionViewDelegate
extension PhotosBaseViewController {

	override func collectionView(
		_ collectionView: UICollectionView,
		willDisplay cell: UICollectionViewCell,
		forItemAt indexPath: IndexPath
	) {
		loadImageForCellAt(indexPath)
	}

	override func collectionView(
		_ collectionView: UICollectionView,
		didEndDisplaying cell: UICollectionViewCell,
		forItemAt indexPath: IndexPath
	) {
		cancelLoadingImageForCellAt(indexPath)
	}
}
