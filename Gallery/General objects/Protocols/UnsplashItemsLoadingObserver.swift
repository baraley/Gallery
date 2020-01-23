//
//  UnsplashItemsLoadingObserver.swift
//  Gallery
//
//  Created by Alexander Baraley on 20.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import Foundation

protocol UnsplashItemsLoadingObserver: AnyObject {

	func itemsLoadingDidStart()
	func itemsLoadingDidFinish(numberOfItems number: Int, locationIndex index: Int)
	func itemsLoadingDidFinishWith(_ error: RequestError)
}
