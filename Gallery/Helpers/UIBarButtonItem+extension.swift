//
//  UIBarButtonItem+extension.swift
//  Gallery
//
//  Created by Alexander Baraley on 12/5/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
	class var loadingBarButtonItem: UIBarButtonItem {
		let activityView = UIActivityIndicatorView(style: .gray)
		let activityItem = UIBarButtonItem(customView: activityView)
		activityView.startAnimating()
		return activityItem
	}
}
