//
//	UITableView+extension.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/10/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

extension UITableView {
	func registerNibForCell<T: UITableViewCell>(_: T.Type) {
		let nib = UINib(nibName: T.identifier, bundle: nil)
		register(nib, forCellReuseIdentifier: T.identifier)
	}
	
	func dequeueCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
		let idenrifier = T.identifier
		guard let cell = dequeueReusableCell(withIdentifier: idenrifier, for: indexPath) as? T else {
			fatalError("Could not dequeue cell with \(idenrifier)")
		}
		return cell
	}
	
	func indexPathForRow(with view: UIView) -> IndexPath? {
		let point = self.convert(CGPoint.zero, from: view)
		return self.indexPathForRow(at: point)
	}
}
