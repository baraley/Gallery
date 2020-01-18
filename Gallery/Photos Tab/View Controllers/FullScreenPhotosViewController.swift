//
//  FullScreenPhotosViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 14.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class FullScreenPhotosViewController: UICollectionViewController {

	// MARK: - Initialization

	private let networkService: NetworkService
	private let authenticationStateProvider: AuthenticationStateProvider

	init(
		networkService: NetworkService,
		authenticationStateProvider: AuthenticationStateProvider,
		collectionViewLayout layout: UICollectionViewLayout
	) {
		self.networkService = networkService
		self.authenticationStateProvider = authenticationStateProvider

		super.init(collectionViewLayout: layout)

		hidesBottomBarWhenPushed = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Properties

	var dataSource: PhotosDataSource? { didSet { dataSourceDidChange() } }

	var photoDidSelectHandler: ((Int) -> Void)?

	private var errorMessageWasShown = false
	private var layout: FullScreenPhotosCollectionViewLayout? {
		return collectionView.collectionViewLayout as? FullScreenPhotosCollectionViewLayout
	}

	private lazy var sharePhotoButton = UIBarButtonItem(
		barButtonSystemItem: .action, target: self, action: #selector(sharePhoto)
	)
	private lazy var likePhotoButton = UIBarButtonItem(
		image: #imageLiteral(resourceName: "like"), style: .plain, target: self, action: #selector(likePhoto)
	)

	private var currentCell: FullScreenCollectionViewCell? { didSet { currentCellDidChange() } }

	// MARK: - Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		initialSetup()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		scrollToSelectedPhoto(animated: false)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		navigationController?.setToolbarHidden(false, animated: true)
		updateCurrentCell()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.setToolbarHidden(true, animated: true)
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

		layout?.itemSize = size

		coordinator.animate(alongsideTransition: { (_) in
			self.collectionViewLayout.invalidateLayout()
			self.currentCell?.updateScrollViewZoomScales()
		})
	}
}

// MARK: - Private
private extension FullScreenPhotosViewController {

	var barsAreHidden: Bool {
		guard let navController = navigationController else {
			return true
		}
		return navController.isNavigationBarHidden && navController.isToolbarHidden
	}

	func initialSetup() {

		layout?.itemSize = collectionView.bounds.size
		collectionView.contentInsetAdjustmentBehavior = .never
		navigationItem.largeTitleDisplayMode = .never

		collectionView.backgroundColor = .white
		collectionView.decelerationRate = .fast
		collectionView.showsHorizontalScrollIndicator = false

		collectionView.register(FullScreenCollectionViewCell.self)
	}

	func updatePhotoBackgroundColor() {
		collectionView.backgroundColor = barsAreHidden ? .black : .white

		if currentCell?.imageView.image == nil {
			currentCell?.loadingViewColor = barsAreHidden ? .white : .black
		}

		if !barsAreHidden {
			updateToolBar()
		}
	}

	// MARK: - Changes

	func currentCellDidChange() {
		if let cell = currentCell, let indexPath = collectionView.indexPath(for: cell) {
			dataSource?.selectedPhotoIndex = indexPath.item
		}

		updateToolBar()
	}

	func dataSourceDidChange() {

		errorMessageWasShown = false

		dataSource?.loadingEventsHandler = { [weak self] (event) in
			self?.handlePhotosLoadingEvent(event)
		}

		collectionView.reloadData()
		collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
	}

	// MARK: - Updates

	func updateCurrentCell() {
		if let cell = collectionView.visibleCells.first as? FullScreenCollectionViewCell {
			currentCell = cell
		}
	}

	func updateToolBar() {
		sharePhotoButton.isEnabled = currentCell?.imageView.image != nil
		likePhotoButton.isEnabled = sharePhotoButton.isEnabled && authenticationStateProvider.isAuthenticated

		if let indexPath = collectionView.indexPathsForVisibleItems.first,
			let photo = dataSource?.photoAt(indexPath.item) {

			likePhotoButton.image = photo.isLiked ? #imageLiteral(resourceName: "unlike") : #imageLiteral(resourceName: "like")
		}
		navigationController?.toolbar.items = [sharePhotoButton, UIBarButtonItem.flexibleSpace, likePhotoButton]
	}

	// MARK: - Photos loading

	func handlePhotosLoadingEvent(_ event: LoadingState) {

		switch event {
		case .startLoading:
			break

		case .loadingDidFinish(let number, let locationIndex):
			errorMessageWasShown = false
			insertPhotos(number, at: locationIndex)

		case .loadingError(let error):
			showError(error)
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

	func scrollToSelectedPhoto(animated: Bool) {
		if let index = dataSource?.selectedPhotoIndex {
			let indexPath = IndexPath(item: index, section: 0)
			collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
		}
	}

	// MARK: - Toolbar actions

	@objc func likePhoto() {

		guard let accessToken = authenticationStateProvider.accessToken,
			let indexPath = collectionView.indexPathsForVisibleItems.first,
			let photo = dataSource?.photoAt(indexPath.item)
		else { return }

		let toggleRequest = TogglePhotoLikeRequest(photo: photo, accessToken: accessToken)

		navigationController?.toolbar.items?.removeLast()
		navigationController?.toolbar.items?.append(UIBarButtonItem.loadingBarButtonItem)

		networkService.performRequest(toggleRequest) { [weak self] (result) in
			guard let self = self else { return }
			DispatchQueue.main.async {
				switch result {
				case .success(let photo):
					self.dataSource?.updatePhotoAt(indexPath.item, with: photo)

					if self.currentCell == self.collectionView.cellForItem(at: indexPath) {
						self.updateToolBar()
					}

				case .failure(let error):
					self.showError(error)
				}
			}
		}
	}

	@objc func sharePhoto() {
		guard let imageData = currentCell?.imageView.image?.jpegData(compressionQuality: 1.0) else { return }

		let vc = UIActivityViewController(activityItems: [imageData], applicationActivities: [])
		vc.popoverPresentationController?.barButtonItem = sharePhotoButton

		present(vc, animated: true, completion: nil)
	}

	// MARK: - Images loading

	func loadImageForCellAt(_ indexPath: IndexPath) {
		guard let photo = dataSource?.photoAt(indexPath.item) else { return }

		let imageRequest = ImageRequest(url: photo.imageURL)

		networkService.performRequest(imageRequest) { [weak self] (result) in
			guard let self = self else { return }
			DispatchQueue.main.async {
				switch result {
				case .success(let image):
					let cell = self.collectionView.cellForItem(at: indexPath) as? FullScreenCollectionViewCell
					cell?.showImage(image)
					self.updateToolBar()

				case .failure(let error):
					self.showError(error)
				}
			}
		}
	}

	func cancelLoadingImageForCellAt(_ indexPath: IndexPath) {
		guard let photo = dataSource?.photoAt(indexPath.item) else { return }

		let imageRequest = ImageRequest(url: photo.imageURL)

		networkService.cancel(imageRequest)
	}

	// MARK: - Gesture recognizers' handlers

	func handlerSingleTapGesture() {

		if let isNavBarHidden = navigationController?.isNavigationBarHidden,
            let isToolBarHidden = navigationController?.isToolbarHidden {

			UIView.animate(withDuration: 0.35) {
				self.navigationController?.isNavigationBarHidden = !isNavBarHidden
				self.navigationController?.isToolbarHidden = !isToolBarHidden

				self.updatePhotoBackgroundColor()
			}
			setNeedsStatusBarAppearanceUpdate()
        }
	}
}

// MARK: - UICollectionViewDataSource
extension FullScreenPhotosViewController {

	override func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return dataSource?.numberOfPhotos ?? 0
	}

	override func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueCell(indexPath: indexPath) as FullScreenCollectionViewCell

		cell.singleTapGestureHandler = { [weak self] in
			self?.handlerSingleTapGesture()
		}
		cell.loadingViewColor = barsAreHidden ? .white : .black

		return cell
	}
}

// MARK: - UICollectionViewDelegate
extension FullScreenPhotosViewController {

	override func collectionView(_ collectionView: UICollectionView,
								 willDisplay cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {
		loadImageForCellAt(indexPath)
	}

	override func collectionView(_ collectionView: UICollectionView,
								 didEndDisplaying cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {

		if let numberOfPhotos = dataSource?.numberOfPhotos,
			indexPath.item > numberOfPhotos - 5 {

			dataSource?.loadMorePhotos()
		}
		cancelLoadingImageForCellAt(indexPath)
		updateCurrentCell()
	}

	override func collectionView(
		_ collectionView: UICollectionView,
		targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint
	) -> CGPoint {

		guard let layout = layout, let cell = currentCell else { return .zero }

		let pageWidth = collectionView.bounds.width + layout.minimumLineSpacing

		let currentCellIndex = collectionView.indexPath(for: cell)?.item ?? 0
		let currentPageOffset = pageWidth * CGFloat(currentCellIndex)

		return CGPoint(x: currentPageOffset, y: 0)
	}
}

// MARK: - StatusBar
extension FullScreenPhotosViewController {

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		.none
	}

    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? false
    }
}
