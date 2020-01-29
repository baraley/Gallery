//
//  CollectionsOfPhotosModelController.swift
//  Gallery
//
//  Created by Alexander Baraley on 22.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import Foundation

class CollectionsOfPhotosModelController:
	UnsplashItemsModelController<PhotoCollectionListRequest>, CollectionsOfPhotosDataSource
{

	var numberOfCollections: Int {
		numberOfItems
	}

	func reloadCollections() {
		reloadItems()
	}

	func loadMoreCollections() {
		loadMoreItems()
	}

	func collectionAt(_ index: Int) -> PhotoCollection? {
		itemAt(index)
	}
}
