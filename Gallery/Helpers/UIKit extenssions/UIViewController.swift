//
//  UIViewController+extensions.swift
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
		guard parent != nil else { return }
		
		willMove(toParent: nil)
		removeFromParent()
		view.removeFromSuperview()
	}
	
	func showAlertWith(_ message: String) {
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
	}

	func showError(_ error: RequestError) {
		switch error {
		case .noInternet, .limitExceeded:
			showAlertWith(error.localizedDescription)
		default:
			print(error.localizedDescription)
		}
	}
}
