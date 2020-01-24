//
//  UnsplashItemsLoadingObserver.swift
//  Gallery
//
//  Created by Alexander Baraley on 20.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

protocol UnsplashItemsLoadingObserver: AnyObject {

	func itemsLoadingDidStart()
	func itemsLoadingDidFinish(numberOfItems number: Int, locationIndex index: Int)
	func itemsLoadingDidFinishWith(_ error: RequestError)
}

extension UnsplashItemsLoadingObserver {

	func itemsLoadingDidStart() { }
	func itemsLoadingDidFinish(numberOfItems number: Int, locationIndex index: Int) { }
	func itemsLoadingDidFinishWith(_ error: RequestError) { }
}

extension UnsplashItemsLoadingObserver where Self: UICollectionViewController {

	func itemsLoadingDidFinish(numberOfItems number: Int, locationIndex index: Int) {
		insertItems(number, at: index)
	}

	func itemsLoadingDidFinishWith(_ error: RequestError) {
		showError(error)
	}

	func insertItems(_ numberOfItems: Int, at index: Int) {
		guard numberOfItems > 0 else { return }

		var indexPaths: [IndexPath] = []

		for i in index..<index + numberOfItems {
			indexPaths.append(IndexPath(item: i, section: 0))
		}
		collectionView.insertItems(at: indexPaths)
	}
}
