//
//  CollectionsOfPhotosViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/28/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class CollectionsOfPhotosViewController:
	UICollectionViewController, UnsplashItemsLoadingObserver, NetworkImagePresenter, LoadingFooterPresenter
{

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
	
	var dataSource: CollectionsOfPhotosDataSource? { didSet { dataSourceDidChange() } }
	var collectionDidSelectHandler: ((Int) -> Void)?

	private(set) weak var activityIndicatorView: UIActivityIndicatorView?
	lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .darkGray
		refreshControl.addTarget(self, action: #selector(refreshCollections), for: .valueChanged)
		return refreshControl
	}()

	// MARK: - Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		initialSetup()
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

	// MARK: - CellsWithNetworkImagePresenter

	typealias CellType = ImageCollectionViewCell

	func imageRequestForImage(at indexPath: IndexPath) -> ImageRequest? {
		guard let collection = dataSource?.collectionAt(indexPath.item) else { return nil }

		return ImageRequest(url: collection.thumbURL)
	}

	// MARK: - Helpers

	func dataSourceDidChange() {
		dataSource?.addObserve(self)
		collectionView.reloadData()
	}
}

// MARK: - Private
private extension CollectionsOfPhotosViewController {

	@objc func refreshCollections() {
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
		dataSource?.loadMoreCollections()
	}

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
