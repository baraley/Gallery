//
//  MessageAlertPresenter.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/23/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

struct MessageAlertPresenter {
	
	func presentMessageAlert(in viewController: UIViewController, with message: String) {
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(okAction)
		viewController.present(alert, animated: true, completion: nil)
	}
}
