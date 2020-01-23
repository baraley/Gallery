//
//  CollectionsOfPhotosCollectionViewLayout.swift
//  Gallery
//
//  Created by Alexander Baraley on 22.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class CollectionsOfPhotosCollectionViewLayout: UICollectionViewFlowLayout {

	override func prepare() {
		super.prepare()

		guard let width = collectionView?.safeAreaLayoutGuide.layoutFrame.size.width,
			let height = collectionView?.bounds.size.height else { return }

		let hSectionInset: CGFloat = width * 0.03
		let vSectionInset: CGFloat = height * 0.03

		sectionInset = UIEdgeInsets(top: vSectionInset, left: hSectionInset, bottom: vSectionInset, right: hSectionInset)
		minimumLineSpacing = vSectionInset
		minimumInteritemSpacing = hSectionInset / 2
		footerReferenceSize = CGSize(width: width, height: height * 0.07)

		var itemWidth: CGFloat = width - 2 * hSectionInset

		if width > height {
			itemWidth = round((itemWidth - minimumInteritemSpacing) / 2)
		}

		let itemHeight = itemWidth * 9 / 16
		
		itemSize = CGSize(width: itemWidth, height: itemHeight)
	}
}
