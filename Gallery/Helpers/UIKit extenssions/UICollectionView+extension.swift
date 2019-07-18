//
//  UICollectionView+extension.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 3/10/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

extension UICollectionView {
	
	func dequeueCell<T:UICollectionViewCell>(indexPath: IndexPath) -> T {
		let bareCell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath)
		guard let cell = bareCell as? T
			else {
				fatalError( "Failed to dequeue a cell with identifier \(T.identifier)")
		}
		return cell
	}
	
	func dequeueSupplementaryView<T:UICollectionReusableView>
		(of kind: String, at indexPath: IndexPath) -> T {
		let bareView = dequeueReusableSupplementaryView(ofKind: kind,
														withReuseIdentifier: T.identifier,
														for: indexPath)
		guard let supplementaryView = bareView as? T
			else {
				fatalError("Failed to dequeue a supplementary view with identifier \(T.identifier)")
		}
		return supplementaryView
	}
}
