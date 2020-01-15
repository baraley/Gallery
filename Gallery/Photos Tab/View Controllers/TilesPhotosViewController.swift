//
//  TilesPhotosViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 11.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class TilesPhotosViewController: UICollectionViewController {

	// MARK: - Initialization

	private let networkService: NetworkService

	init(networkService: NetworkService, collectionViewLayout layout: UICollectionViewLayout) {
		self.networkService = networkService
		
		super.init(collectionViewLayout: layout)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Properties

	var dataSource: (PhotosDataSource & PinterestCollectionViewLayoutDataSource)? { didSet { dataSourceDidChange() } }

	var photoDidSelectHandler: ((Int) -> Void)?

	private var errorMessageWasShown = false
	private weak var activityIndicatorView: UIActivityIndicatorView?
	private var layout: PinterestCollectionViewLayout? {
		return collectionView.collectionViewLayout as? PinterestCollectionViewLayout
	}

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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		dataSourceDidChange()
		scrollToSelectedPhoto(animated: false)
	}
}

// MARK: - Private
private extension TilesPhotosViewController {

	func initialSetup() {
		collectionView.refreshControl = refreshControl
		collectionView.register(TileCollectionViewCell.self)
		collectionView.register(
			CollectionViewLoadingFooter.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter
		)
		collectionView.backgroundColor = .white
	}

	func dataSourceDidChange() {

		errorMessageWasShown = false

		dataSource?.loadingEventsHandler = { [weak self] (event) in
			self?.handlePhotosLoadingEvent(event)
		}

		layout?.dataSource = dataSource
		layout?.reset()

		collectionView.reloadData()
		collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
	}

	@objc func refreshPhotos() {
		layout?.reset()
		dataSource?.reloadPhotos()
		collectionView.reloadData()
	}

	func handlePhotosLoadingEvent(_ event: LoadingState) {

		switch event {
		case .startLoading:
			if !refreshControl.isRefreshing {
				activityIndicatorView?.startAnimating()
			}
		case .loadingDidFinish(let number, let locationIndex):
			refreshControl.endRefreshing()
			activityIndicatorView?.stopAnimating()

			errorMessageWasShown = false
			insertPhotos(number, at: locationIndex)

		case .loadingError(let error):
			refreshControl.endRefreshing()
			activityIndicatorView?.stopAnimating()
			showError(error)
		}
	}

	func scrollToSelectedPhoto(animated: Bool) {
		if let index = dataSource?.selectedPhotoIndex {
			let indexPath = IndexPath(item: index, section: 0)
			collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
		}
	}

	func insertPhotos(_ numberOfPhotos: Int, at index: Int) {
		guard numberOfPhotos > 0 else { return }

		var indexPaths: [IndexPath] = []

		for i in index..<index + numberOfPhotos {
			indexPaths.append(IndexPath(item: i, section: 0))
		}
		collectionView?.insertItems(at: indexPaths)
	}

	func loadThumbForCellAt(_ indexPath: IndexPath) {
		guard let photo = dataSource?.photoAt(indexPath.item) else { return }

		let imageRequest = ImageRequest(url: photo.thumbURL)

		networkService.performRequest(imageRequest) { [weak self] (result) in
			guard let self = self else { return }
			DispatchQueue.main.async {
				switch result {
				case .success(let thumb):
					let cell = self.collectionView.cellForItem(at: indexPath) as? TileCollectionViewCell
					cell?.imageView.image = thumb

				case .failure(let error):
					self.self.showError(error)
				}
			}
		}
	}

	func cancelLoadingThumbForCellAt(_ indexPath: IndexPath) {
		guard let photo = dataSource?.photoAt(indexPath.item) else { return }

		let imageRequest = ImageRequest(url: photo.thumbURL)

		networkService.cancel(imageRequest)
	}
}

// MARK: - UICollectionViewDataSource
extension TilesPhotosViewController {

	override func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return dataSource?.numberOfPhotos ?? 0
	}

	override func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return collectionView.dequeueCell(indexPath: indexPath) as TileCollectionViewCell
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
extension TilesPhotosViewController {

	override func collectionView(_ collectionView: UICollectionView,
								 willDisplay cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {
		loadThumbForCellAt(indexPath)
	}

	override func collectionView(_ collectionView: UICollectionView,
								 didSelectItemAt indexPath: IndexPath) {
		photoDidSelectHandler?(indexPath.item)
	}

	override func collectionView(_ collectionView: UICollectionView,
								 didEndDisplaying cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {
		cancelLoadingThumbForCellAt(indexPath)
	}

	override func collectionView(_ collectionView: UICollectionView,
								 willDisplaySupplementaryView view: UICollectionReusableView,
								 forElementKind elementKind: String, at indexPath: IndexPath) {

		guard let footer = view as? CollectionViewLoadingFooter else { return }
		activityIndicatorView = footer.activityIndicator

		dataSource?.loadMorePhotos()
	}
}
