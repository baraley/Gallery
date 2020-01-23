//
//  FullScreenPhotosViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 14.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class FullScreenPhotosViewController: PhotosBaseViewController {

	// MARK: - Properties

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

	private var currentCellIndexPath: IndexPath? {
		guard let cell = currentCell else { return nil }

		return collectionView.indexPath(for: cell)
	}

	// MARK: - Life cycle

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		navigationController?.setToolbarHidden(false, animated: true)
		currentCell = collectionView.visibleCells.first as? FullScreenCollectionViewCell
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.setToolbarHidden(true, animated: true)
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		layout?.itemSize = size

		coordinator.animate(alongsideTransition: { (_) in
			self.currentCell?.updateScrollViewZoomScales()
		})
	}

	// MARK: - Overridden

	 override func initialSetup() {
		 super.initialSetup()

		hidesBottomBarWhenPushed = true

		navigationItem.largeTitleDisplayMode = .never

		layout?.itemSize = collectionView.bounds.size

		collectionView.contentInsetAdjustmentBehavior = .never
		collectionView.backgroundColor = .white
		collectionView.decelerationRate = .fast
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.register(FullScreenCollectionViewCell.self)
	}

	// MARK: - Images loading

	override func handleImageLoadingResult(_ result: Result<UIImage, RequestError>, forCellAt indexPath: IndexPath) {
		switch result {
		case .success(let image):
			let cell = collectionView.cellForItem(at: indexPath) as? FullScreenCollectionViewCell
			cell?.showImage(image)
			if indexPath == currentCellIndexPath {
				updateToolBar()
			}

		case .failure(let error):
				showError(error)
		}
	}
}

// MARK: - Private
private extension FullScreenPhotosViewController {

	// MARK: - Setup

	var barsAreHidden: Bool {
		guard let navController = navigationController else { return false }

		return navController.isNavigationBarHidden && navController.isToolbarHidden
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
		dataSource?.selectedPhotoIndex = currentCellIndexPath?.item
		updateToolBar()
	}

	// MARK: - Updates

	func updateToolBar() {
		let hasImage = currentCell?.imageView.image != nil
		let isAuthenticated = authenticationStateProvider.isAuthenticated

		sharePhotoButton.isEnabled = hasImage

		if let indexPath = currentCellIndexPath,
			let photo = dataSource?.photoAt(indexPath.item) {

			likePhotoButton.isEnabled = hasImage && isAuthenticated
			likePhotoButton.image = photo.isLiked ? #imageLiteral(resourceName: "unlike") : #imageLiteral(resourceName: "like")
		}
		navigationController?.toolbar.items = isAuthenticated ?
			[sharePhotoButton, .flexibleSpace, likePhotoButton] : [sharePhotoButton, .flexibleSpace]
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

					if self.currentCellIndexPath == indexPath {
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

	override func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {

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

	override func collectionView(
		_ collectionView: UICollectionView,
		willDisplay cell: UICollectionViewCell,
		forItemAt indexPath: IndexPath
	) {
		super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)

		if let numberOfPhotos = dataSource?.numberOfPhotos,
			indexPath.item > numberOfPhotos - 5 {
			dataSource?.loadMorePhotos()
		}
	}

	override func collectionView(
		_ collectionView: UICollectionView,
		didEndDisplaying cell: UICollectionViewCell,
		forItemAt indexPath: IndexPath
	) {
		super.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
		
		currentCell = collectionView.visibleCells.first as? FullScreenCollectionViewCell
	}

	override func collectionView(
		_ collectionView: UICollectionView,
		targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint
	) -> CGPoint {

		guard let layout = layout, let indexPath = currentCellIndexPath else {
			return .zero
		}

		let pageWidth = collectionView.bounds.width + layout.minimumLineSpacing
		let currentPageOffset = pageWidth * CGFloat(indexPath.item)

		return CGPoint(x: currentPageOffset, y: 0)
	}
}

// MARK: - StatusBar
extension FullScreenPhotosViewController {

	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		.none
	}

	override var prefersStatusBarHidden: Bool {
		barsAreHidden
	}
}
