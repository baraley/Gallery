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
		let nib = UINib(nibName: T.stringIdentifier, bundle: nil)
		register(nib, forCellReuseIdentifier: T.stringIdentifier)
	}

	func register<T: UITableViewCell>(_: T.Type) {
		register(T.self, forCellReuseIdentifier: T.stringIdentifier)
	}
	
	func dequeueCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
		let identifier = T.stringIdentifier
		guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
			fatalError("Could not dequeue cell with \(identifier)")
		}
		return cell
	}
	
	func indexPathForRow(with view: UIView) -> IndexPath? {
		let point = self.convert(CGPoint.zero, from: view)
		return self.indexPathForRow(at: point)
	}
}

// MARK: - IndexPath -
extension IndexPath {
	static var first: IndexPath {
		return IndexPath(row: 0, section: 0)
	}
}
