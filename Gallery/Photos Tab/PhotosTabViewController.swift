//
//  PhotosTabViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 11.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

protocol PhotosTabCollectionViewDataSource: (UICollectionViewDataSource & PinterestCollectionViewLayoutDataSource) {

	var selectedPhotoIndex: Int? { get }
	var eventsHandler: ((LoadingEvent) -> Void)? { get set }

	func reloadPhotos()
	func loadMorePhotos()

	func collectionView(_ collectionView: UICollectionView, loadThumbForCellAt indexPath: IndexPath)
	func collectionView(_ collectionView: UICollectionView, cancelLoadingThumbForCellAt indexPath: IndexPath)
}

class PhotosTabViewController: UICollectionViewController {

	// MARK: - Initialization

	override init(collectionViewLayout layout: UICollectionViewLayout) {
		super.init(collectionViewLayout: layout)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Properties

	var dataSource: PhotosTabCollectionViewDataSource? { didSet { dataSourceDidChange() } }

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

		initialConfiguration()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		scrollToSelectedPhoto(animated: false)
	}
}

// MARK: - Private
private extension PhotosTabViewController {

	func initialConfiguration() {
		collectionView.refreshControl = refreshControl
		collectionView.register(ImageCollectionViewCell.self)
		collectionView.register(
			CollectionViewLoadingFooter.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter
		)
		collectionView.backgroundColor = .white
	}

	func dataSourceDidChange() {

		errorMessageWasShown = false

		dataSource?.eventsHandler = { [weak self] (event) in
			self?.handleLoadingEvent(event)
		}

		layout?.dataSource = dataSource
		layout?.reset()

		collectionView.dataSource = dataSource
		collectionView.reloadData()
		collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
	}

	@objc func refreshPhotos() {
		layout?.reset()
		dataSource?.reloadPhotos()
		collectionView.reloadData()
	}

	func handleLoadingEvent(_ event: LoadingEvent) {

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
}

// MARK: - UICollectionViewDelegate
extension PhotosTabViewController {

	override func collectionView(_ collectionView: UICollectionView,
								 willDisplay cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {
		dataSource?.collectionView(collectionView, loadThumbForCellAt: indexPath)
	}

	override func collectionView(_ collectionView: UICollectionView,
								 didSelectItemAt indexPath: IndexPath) {
		photoDidSelectHandler?(indexPath.item)
	}

	override func collectionView(_ collectionView: UICollectionView,
								 didEndDisplaying cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {
		dataSource?.collectionView(collectionView, cancelLoadingThumbForCellAt: indexPath)
	}

	override func collectionView(_ collectionView: UICollectionView,
								 willDisplaySupplementaryView view: UICollectionReusableView,
								 forElementKind elementKind: String, at indexPath: IndexPath) {

		guard let footer = view as? CollectionViewLoadingFooter else { return }
		activityIndicatorView = footer.activityIndicator

		dataSource?.loadMorePhotos()
	}
}
