//
//  PinterestCollectionViewLayout.swift
//  Gallery
//
//  Created by Alexander Baraley on 10/19/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

protocol PinterestCollectionViewLayoutDataSource: class {
	func collectionView(_ collectionView: UICollectionView,
						heightForCellAtIndexPath indexPath:IndexPath,
						whileCellWidthIs cellWidth: CGFloat) -> CGFloat
}

class PinterestCollectionViewLayout: UICollectionViewLayout {
	
	var interItemsSpacing: CGFloat = 5
	var numberOfColumns: Int {
		guard let collectionView = collectionView else { return 0 }
		return collectionView.bounds.width > collectionView.bounds.height ? 4 : 2
	}
	
	weak var dataSource: PinterestCollectionViewLayoutDataSource?
	
	private let footerHeight: CGFloat = 50.0
	
	private var frameCalculator: PinterestLayoutFrameCalculator?
	
	// MARK: - Cache properties
	
	private var cellLayoutAttributes: [UICollectionViewLayoutAttributes] = []
	
	private var footerLayoutAttributes: UICollectionViewLayoutAttributes? = nil
	
	// MARK: - Computed properties
	
	private var contentWidth: CGFloat {
		guard let collectionView = collectionView else {
			return 0
		}
		let insets = collectionView.contentInset
		return collectionView.bounds.width - (insets.left + insets.right)
	}
	
	private var columnWidth: CGFloat {
		return contentWidth / CGFloat(numberOfColumns)
	}
	
	// MARK: - Helpers
	
	func reset() {
		frameCalculator = PinterestLayoutFrameCalculator(
			contentWidth: contentWidth, cellSpacing: interItemsSpacing, numberOfColumns: numberOfColumns
		)
		cellLayoutAttributes.removeAll()
	}
	
	private func frameForFooterSupplementaryView() -> CGRect {
		guard let collectionView = collectionView, let frameCalculator = frameCalculator else {
			return .zero
		}
		
		let origin = CGPoint(x: 0, y: frameCalculator.contentHeight)
		let size = CGSize(width: collectionView.bounds.width, height: footerHeight)
		
		return CGRect(origin: origin, size: size)
	}
}

// MARK: - Overriden
extension PinterestCollectionViewLayout {
	
	override func prepare() {
		
		guard cellLayoutAttributes.isEmpty == true, let collectionView = collectionView else {
			return
		}

		for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
			let indexPath = IndexPath(item: item, section: 0)

			let _ = layoutAttributesForItem(at: indexPath)
		}

		let _ = layoutAttributesForSupplementaryView(
			ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0))
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		
		var atttributes = cellLayoutAttributes.filter { return $0.frame.intersects(rect) }
		
		if let footerAttributs = footerLayoutAttributes, footerAttributs.frame.intersects(rect) {
			atttributes.append(footerAttributs)
		}
		return atttributes
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		
		if indexPath.item < cellLayoutAttributes.count {
			return cellLayoutAttributes[indexPath.item]
		}

		guard let collectionView = collectionView, let frameCalculator = frameCalculator else {
			return nil
		}
		
		let cellHeight = dataSource?.collectionView(
			collectionView, heightForCellAtIndexPath: indexPath, whileCellWidthIs: columnWidth
		) ?? 0
		
		let fullheight = interItemsSpacing * 2 + cellHeight
		
		let frame = frameCalculator.frameForItem(with: CGSize(width: columnWidth, height: fullheight))
		
		let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
		attributes.frame = frame
		
		cellLayoutAttributes.append(attributes)
		
		return attributes
	}
	
	override func layoutAttributesForSupplementaryView(
		ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		
		guard elementKind == UICollectionView.elementKindSectionFooter else { return nil }
		
		if footerLayoutAttributes != nil {
			return footerLayoutAttributes
		}
		
		let frame = frameForFooterSupplementaryView()
		let attributes = UICollectionViewLayoutAttributes(
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: indexPath
		)
		attributes.frame = frame
		
		footerLayoutAttributes = attributes
		
		return attributes
	}
	
	override var collectionViewContentSize: CGSize {
		let contentHeight = frameCalculator?.contentHeight ?? 0
		return CGSize(width: contentWidth, height: contentHeight + footerHeight)
	}
	
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		guard let collectionView = collectionView else { return false }
		
		let equal = newBounds.size.equalTo(collectionView.bounds.size)
		
		return !equal
	}
	
	override func invalidateLayout() {
		super.invalidateLayout()
		
		footerLayoutAttributes = nil
		
		if frameCalculator?.contentWidth != contentWidth {
			reset()
		}
	}
}
