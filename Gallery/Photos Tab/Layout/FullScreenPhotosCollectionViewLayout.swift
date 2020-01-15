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

		minimumLineSpacing = round(itemSize.width * 0.1)
	}

	override func targetContentOffset(
		forProposedContentOffset proposedContentOffset: CGPoint,
		withScrollingVelocity velocity: CGPoint
	) -> CGPoint {

		guard let currentContentOffset = collectionView?.contentOffset else {
			return super.targetContentOffset(
				forProposedContentOffset: proposedContentOffset,
				withScrollingVelocity: velocity
			)
		}

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
}
