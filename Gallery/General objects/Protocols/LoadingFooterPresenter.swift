//
//  LoadingFooterPresenter.swift
//  Gallery
//
//  Created by Alexander Baraley on 24.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

protocol LoadingFooterPresenter: UICollectionViewController {

	var activityIndicatorView: UIActivityIndicatorView? { get }
	var refreshControl: UIRefreshControl { get set }
}

extension LoadingFooterPresenter where Self: UICollectionViewController & UnsplashItemsLoadingObserver {

	func itemsLoadingDidStart() {

		if !refreshControl.isRefreshing {
			activityIndicatorView?.startAnimating()
		}
	}

	func itemsLoadingDidFinish(numberOfItems number: Int, locationIndex index: Int) {

		insertItems(number, at: index)

		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()
	}

	func itemsLoadingDidFinishWith(_ error: RequestError) {
		showError(error)

		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()
	}
}
