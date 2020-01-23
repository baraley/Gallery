//
//  PhotosBaseViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 19.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//


import UIKit

class PhotosBaseViewController: UICollectionViewController, UnsplashItemsLoadingObserver {

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

	var photoDidSelectHandler: ((Int) -> Void)?

	var errorMessageWasShown = false

	// MARK: - Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		initialSetup()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		scrollToSelectedPhoto(animated: false)
	}

	// MARK: - UnsplashItemsLoadingObserver

	func itemsLoadingDidStart() { }

	func itemsLoadingDidFinish(numberOfItems number: Int, locationIndex index: Int) {
		errorMessageWasShown = false
		insertPhotos(number, at: index)
	}

	func itemsLoadingDidFinishWith(_ error: RequestError) {
		showError(error)
	}

	// MARK: - Setup

	func initialSetup() {

		collectionView.backgroundColor = .white
	}

	// MARK: - Photos loading

	func insertPhotos(_ numberOfPhotos: Int, at index: Int) {
		guard numberOfPhotos > 0 else { return }

		var indexPaths: [IndexPath] = []

		for i in index..<index + numberOfPhotos {
			indexPaths.append(IndexPath(item: i, section: 0))
		}
		collectionView?.insertItems(at: indexPaths)
	}

	// MARK: - Images loading

	var photoImageRequestKeyPath: KeyPath<Photo, URL> {
		\Photo.imageURL
	}

	func loadImageForCellAt(_ indexPath: IndexPath) {
		guard let photo = dataSource?.photoAt(indexPath.item) else { return }

		let url = photo[keyPath: photoImageRequestKeyPath]
		let imageRequest = ImageRequest(url: url)

		networkService.performRequest(imageRequest) { [weak self] (result) in
			DispatchQueue.main.async {
				self?.handleImageLoadingResult(result, forCellAt: indexPath)
			}
		}
	}

	func cancelLoadingImageForCellAt(_ indexPath: IndexPath) {
		if let photo = dataSource?.photoAt(indexPath.item) {
			let url = photo[keyPath: photoImageRequestKeyPath]
			let imageRequest = ImageRequest(url: url)

			networkService.cancel(imageRequest)
		}
	}

	func handleImageLoadingResult(_ result: Result<UIImage, RequestError>, forCellAt indexPath: IndexPath) {
		switch result {
		case .success(_): 			break
		case .failure(let error): 	showError(error)
		}
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
		errorMessageWasShown = false

		dataSource?.addObserve(self)
		
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
