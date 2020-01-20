//
//  PhotosDataSourceObserver.swift
//  Gallery
//
//  Created by Alexander Baraley on 20.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import Foundation

protocol PhotosDataSourceObserver: AnyObject {

	func photosLoadingDidStart()
	func photosLoadingDidFinish(numberOfPhotos number: Int, locationIndex index: Int)
	func photosLoadingDidFinishWith(_ error: RequestError)
}
