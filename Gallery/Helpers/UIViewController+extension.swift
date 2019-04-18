//
//  UIViewController+extention.swift
//  Gallery
//
//  Created by Alexander Baraley on 8/20/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

extension UIViewController {
	
	func add(_ child: UIViewController) {
		addChild(child)
		view.addSubview(child.view)
		child.didMove(toParent: self)
	}
	
	func remove() {
		guard parent != nil else {
			return
		}
		
		willMove(toParent: nil)
		removeFromParent()
		view.removeFromSuperview()
	}
	
	func showAlertWith(_ message: String) {
		let presenter = MessageAlertPresenter()
		
		presenter.presentMessageAlert(in: self, with: message)
	}
}
