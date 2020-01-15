//
//  FullScreenPhotosCollectionViewLayout.swift
//  Gallery
//
//  Created by Alexander Baraley on 12.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class FullScreenPhotosCollectionViewLayout: UICollectionViewFlowLayout {

	override func prepare() {
		super.prepare()

		guard let collectionView = collectionView else { return }

		scrollDirection = .horizontal
		itemSize = collectionView.bounds.size

		minimumLineSpacing = 0.0
	}
}
