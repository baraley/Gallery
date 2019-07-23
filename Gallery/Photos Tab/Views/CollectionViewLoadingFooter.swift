//
//  CollectionViewLoadingFooter.swift
//  Gallery
//
//  Created by Alexander Baraley on 5/26/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class CollectionViewLoadingFooter: UICollectionReusableView {
	
	var activityIndicator: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(style: .whiteLarge)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.color = .black
		view.hidesWhenStopped = true
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupLayout()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupLayout()
	}
	
	private func setupLayout() {
		translatesAutoresizingMaskIntoConstraints = false
		addSubview(activityIndicator)
		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
			])
	}
}
