//
//  UICollectionView+extension.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 3/10/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

extension UICollectionView {

	func register<T: UICollectionViewCell>(_: T.Type) {
		register(T.self, forCellWithReuseIdentifier: T.stringIdentifier)
    }

	func register<T: UICollectionReusableView>(_: T.Type, forSupplementaryViewOfKind kind: String) {
		register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.stringIdentifier)
	}
	
	func dequeueCell<T:UICollectionViewCell>(indexPath: IndexPath) -> T {
		let bareCell = dequeueReusableCell(withReuseIdentifier: T.stringIdentifier, for: indexPath)
		guard let cell = bareCell as? T
			else {
				fatalError( "Failed to dequeue a cell with stringIdentifier \(T.stringIdentifier)")
		}
		return cell
	}
	
	func dequeueSupplementaryView<T:UICollectionReusableView>(of kind: String, at indexPath: IndexPath) -> T {
		let bareView = dequeueReusableSupplementaryView(ofKind: kind,
														withReuseIdentifier: T.stringIdentifier,
														for: indexPath)
		guard let supplementaryView = bareView as? T
			else {
				fatalError("Failed to dequeue a supplementary view with stringIdentifier \(T.stringIdentifier)")
		}
		return supplementaryView
	}
}
