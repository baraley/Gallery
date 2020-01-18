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

		scrollDirection = .horizontal
		minimumLineSpacing = round(itemSize.width * 0.1)
	}

	override func targetContentOffset(
		forProposedContentOffset proposedContentOffset: CGPoint,
		withScrollingVelocity velocity: CGPoint
	) -> CGPoint {

		let currentContentOffset = collectionView?.contentOffset ?? .zero

		let pageWidth = itemSize.width + minimumLineSpacing
		let currentPage = round(currentContentOffset.x / pageWidth)
		let currentPageOffset = pageWidth * currentPage

		let nextPageCondition = proposedContentOffset.x > (currentPageOffset + pageWidth / 2)

		if velocity.x > 0.5 || nextPageCondition  {
			return CGPoint(x: (currentPage + 1) * pageWidth, y: 0)
		}

		let previousPageCondition = proposedContentOffset.x < (currentPageOffset - pageWidth / 2)

		if velocity.x < -0.5 || previousPageCondition {
			return CGPoint(x: (currentPage - 1) * pageWidth, y: 0)
		}

		return CGPoint(x: currentPageOffset, y: 0)
	}

	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		collectionView?.bounds.size != newBounds.size
	}
}
