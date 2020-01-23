//
//  PhotosModelController.swift
//  Gallery
//
//  Created by Alexander Baraley on 11.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit.UICollectionView

class PhotosModelController: UnsplashItemsModelController<PhotoListRequest>, PhotosDataSource {

	// MARK: - Public

	var numberOfPhotos: Int {
		numberOfItems
	}

	var selectedPhotoIndex: Int?

	func reloadPhotos() {
		reloadItems()
	}

	func loadMorePhotos() {
		loadMoreItems()
	}

	func photoAt(_ index: Int) -> Photo? {
		itemAt(index)
	}

	func updatePhotoAt(_ index: Int, with photo: Photo) {
		updateItemAt(index, with: photo)
	}
}

// MARK: - TilesCollectionViewLayoutDataSource -
extension PhotosModelController: TilesCollectionViewLayoutDataSource {

	func collectionView(
		_ collectionView: UICollectionView,
		heightForCellAtIndexPath indexPath: IndexPath,
		whileCellWidthIs cellWidth: CGFloat
	) -> CGFloat {

		let photo = items[indexPath.item]

		let sizeRatio = photo.sizeRatio

		return (cellWidth * sizeRatio).rounded()
	}
}

