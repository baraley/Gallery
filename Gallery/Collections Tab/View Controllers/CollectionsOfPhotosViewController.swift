//
//  CollectionsOfPhotosViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/28/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class CollectionsOfPhotosViewController: UICollectionViewController, PhotosDataSourceObserver {

	// MARK: - Initialization

	let networkService: NetworkService

	init(
		networkService: NetworkService,
		collectionViewLayout layout: UICollectionViewLayout
	) {
		self.networkService = networkService

		super.init(collectionViewLayout: layout)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Properties
	
	var dataSource: CollectionsOfPhotosModelController? { didSet { dataSourceDidChange() } }
	var collectionDidSelectHandler: ((Int) -> Void)?

	private weak var activityIndicatorView: UIActivityIndicatorView?
	private var errorMessageWasShown = false
	private lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .darkGray
		refreshControl.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
		return refreshControl
	}()

	// MARK: - Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		initialSetup()
	}

	// MARK: - PhotosDataSourceObserver

	func photosLoadingDidStart() {
		if !refreshControl.isRefreshing {
			activityIndicatorView?.startAnimating()
		}
	}

	func photosLoadingDidFinish(numberOfPhotos number: Int, locationIndex index: Int) {
		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()

		errorMessageWasShown = false
		insertCollections(number, at: index)
	}

	func photosLoadingDidFinishWith(_ error: RequestError) {
		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()
		showError(error)
	}

	// MARK: - Setup

	func initialSetup() {

		collectionView.backgroundColor = .white
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.keyboardDismissMode = .onDrag
		collectionView.refreshControl = refreshControl
		collectionView.register(CollectionOfPhotosCollectionViewCell.self)
		collectionView.register(CollectionViewLoadingFooter.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter
		)
	}

	// MARK: - Collections loading

	func insertCollections(_ numberOfCollections: Int, at index: Int) {
		guard numberOfCollections > 0 else { return }

		var indexPaths: [IndexPath] = []

		for i in index..<index + numberOfCollections {
			indexPaths.append(IndexPath(item: i, section: 0))
		}
		collectionView?.insertItems(at: indexPaths)
	}

	// MARK: - Images loading

	var imageRequestKeyPath: KeyPath<PhotoCollection, URL> {
		\PhotoCollection.thumbURL
	}

	func loadImageForCellAt(_ indexPath: IndexPath) {
		guard let collection = dataSource?.collectionAt(indexPath.item) else { return }

		let url = collection[keyPath: imageRequestKeyPath]
		let imageRequest = ImageRequest(url: url)

		networkService.performRequest(imageRequest) { [weak self] (result) in
			DispatchQueue.main.async {
				self?.handleImageLoadingResult(result, forCellAt: indexPath)
			}
		}
	}

	func cancelLoadingImageForCellAt(_ indexPath: IndexPath) {
		if let photo = dataSource?.collectionAt(indexPath.item) {
			let url = photo[keyPath: imageRequestKeyPath]
			let imageRequest = ImageRequest(url: url)

			networkService.cancel(imageRequest)
		}
	}

	func handleImageLoadingResult(_ result: Result<UIImage, RequestError>, forCellAt indexPath: IndexPath) {
		switch result {
		case .success(let image):
			let cell = self.collectionView.cellForItem(at: indexPath) as? CollectionOfPhotosCollectionViewCell
			cell?.imageView.image = image
		case .failure(let error):
			showError(error)
		}
	}

	// MARK: - Helpers

	func dataSourceDidChange() {
		errorMessageWasShown = false

		dataSource?.addObserve(self)

		collectionView.reloadData()
	}
}

// MARK: - Private
private extension CollectionsOfPhotosViewController {

	@objc func refreshPhotos() {
		dataSource?.reloadCollections()
		collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDataSource
extension CollectionsOfPhotosViewController {

	override func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
		return dataSource?.numberOfCollections ?? 0
	}

	override func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {

		let cell = collectionView.dequeueCell(indexPath: indexPath) as CollectionOfPhotosCollectionViewCell
		cell.cornerRadius = 10
		cell.title = dataSource?.collectionAt(indexPath.item)?.title

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
extension CollectionsOfPhotosViewController {

	override func collectionView(
		_ collectionView: UICollectionView,
		didSelectItemAt indexPath: IndexPath
	) {
		collectionDidSelectHandler?(indexPath.item)
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

	override func collectionView(
		_ collectionView: UICollectionView,
		willDisplay cell: UICollectionViewCell,
		forItemAt indexPath: IndexPath
	) {
		loadImageForCellAt(indexPath)

		if let numberOfPhotos = dataSource?.numberOfCollections,
			indexPath.item > numberOfPhotos - 5 {
			dataSource?.loadMorePhotos()
		}
	}

	override func collectionView(
		_ collectionView: UICollectionView,
		didEndDisplaying cell: UICollectionViewCell,
		forItemAt indexPath: IndexPath
	) {
		cancelLoadingImageForCellAt(indexPath)
	}
}
