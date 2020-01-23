//
//  PhotosDataSource.swift
//  Gallery
//
//  Created by Alexander Baraley on 14.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

protocol PhotosDataSource: AnyObject {

	var numberOfPhotos: Int { get }
	var selectedPhotoIndex: Int? { get set }
	
	func reloadPhotos()
	func loadMorePhotos()

	func photoAt(_ index: Int) -> Photo?
	func updatePhotoAt(_ index: Int, with photo: Photo)

	func addObserve(_ observer: UnsplashItemsLoadingObserver)
	func removeObserver(_ observer: UnsplashItemsLoadingObserver)
}
