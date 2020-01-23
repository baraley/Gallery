//
//  CollectionsOfPhotosDataSource.swift
//  Gallery
//
//  Created by Alexander Baraley on 23.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import Foundation

protocol CollectionsOfPhotosDataSource: AnyObject {

	var numberOfCollections: Int { get }

	func reloadCollections()
	func loadMoreCollections()

	func collectionAt(_ index: Int) -> PhotoCollection?

	func addObserve(_ observer: UnsplashItemsLoadingObserver)
	func removeObserver(_ observer: UnsplashItemsLoadingObserver)
}
