//
//  SMMosaicLayout.swift
//  PlutoLayout
//
//  Created by mac on 11.03.2020.
//  Copyright © 2020 Octopus Baba. All rights reserved.
//

import UIKit

extension CGSize {

    mutating func multiply(by value: CGFloat) {
        width *= value
        height *= value
    }
}

protocol SMMosaicLayoutDataSource: class {

    func contentSizeOfItemAt(_ indexPath: IndexPath) -> CGSize
}

class SMMosaicLayout: UICollectionViewLayout {

    private enum RowType: Int, CaseIterable, Equatable {
        case singleItem = 1
        case twoItems

        static func random() -> RowType {
            allCases.randomElement() ?? .singleItem
        }
    }

    weak var dataSource: SMMosaicLayoutDataSource?
    var layoutInsets: UIEdgeInsets = .zero
    var spacing: CGFloat = 0

    private let footerHeight: CGFloat = 50.0
    private lazy var contentBounds: CGRect = initialContentBounds
    private var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    private var footerAttributes = UICollectionViewLayoutAttributes(
        forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
        with: IndexPath(item: 0, section: 0)
    )


    // MARK: - Computed properties

    private var initialContentBounds: CGRect {
        CGRect(origin: CGPoint(x: layoutInsets.left, y: layoutInsets.top), size: .zero)
    }

    private var rowWidth: CGFloat {
        guard let collectionView: UICollectionView = collectionView else { return 0 }

        return collectionView.bounds.width - (layoutInsets.left + layoutInsets.right)
    }

    private var footerFrame: CGRect {
        guard let collectionView: UICollectionView = collectionView else { return .zero }

        let origin = CGPoint(x: 0, y: contentBounds.height + layoutInsets.bottom)
        let size = CGSize(width: collectionView.bounds.width, height: footerHeight)

        return CGRect(origin: origin, size: size)
    }

    // MARK: - Public methods

    func reset() {
        cachedAttributes.removeAll()
        contentBounds = initialContentBounds
    }

    // MARK: - Private methods

    private func computeCellsAttributes() {

        guard let collectionView: UICollectionView = collectionView else { return }

        var currentIndex: Int = cachedAttributes.isEmpty ? 0 : cachedAttributes.count

        let itemsNumber: Int = collectionView.numberOfItems(inSection: 0)

        while currentIndex < itemsNumber {

            let rowType: RowType = currentIndex < itemsNumber - 1 ? RowType.random() : .singleItem

            let currentItemIndexPath = IndexPath(item: currentIndex, section: 0)

            guard let dataSource: SMMosaicLayoutDataSource = dataSource else { return }

            switch rowType {
            case .singleItem:

                var itemSize: CGSize = dataSource.contentSizeOfItemAt(currentItemIndexPath)

                itemSize.multiply(by: rowWidth / itemSize.width)

                let itemOrigin = CGPoint(x: contentBounds.origin.x, y: contentBounds.maxY + spacing)
                let frame: CGRect = CGRect(origin: itemOrigin, size: itemSize)

                let attributes: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: currentItemIndexPath)
                attributes.frame = frame

                cachedAttributes.append(attributes)
                contentBounds = contentBounds.union(frame)

            case .twoItems:

                let rightItemIndexPath: IndexPath = IndexPath(item: currentItemIndexPath.item + 1, section: 0)

                var leftItemSize: CGSize = dataSource.contentSizeOfItemAt(currentItemIndexPath)
                var rightItemSize: CGSize = dataSource.contentSizeOfItemAt(rightItemIndexPath)

                rightItemSize.multiply(by: leftItemSize.height / rightItemSize.height)

                let rowScale: CGFloat = (rowWidth - spacing) / (leftItemSize.width + rightItemSize.width)

                leftItemSize.multiply(by: rowScale)
                rightItemSize.multiply(by: rowScale)

                let leftItemOrigin: CGPoint = CGPoint(x: contentBounds.origin.x, y: contentBounds.maxY + spacing)
                let leftItemFrame: CGRect = CGRect(origin: leftItemOrigin, size: leftItemSize)

                let rightItemOrigin = CGPoint(x: leftItemOrigin.x + leftItemSize.width + spacing, y: leftItemOrigin.y)
                let rightItemFrame: CGRect = CGRect(origin: rightItemOrigin, size: rightItemSize)

                let leftAttributes: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: currentItemIndexPath)
                let rightAttributes: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: rightItemIndexPath)

                leftAttributes.frame = leftItemFrame
                rightAttributes.frame = rightItemFrame

                cachedAttributes.append(contentsOf: [leftAttributes, rightAttributes])
                contentBounds = contentBounds.union(leftItemFrame)
            }

            currentIndex += rowType.rawValue
        }
    }

    private func binarySearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }

        let mid: Int = (start + end) / 2
        let attribute: UICollectionViewLayoutAttributes = cachedAttributes[mid]

        if attribute.frame.intersects(rect) {
            return mid
        } else {
            if attribute.frame.maxY < rect.minY {
                return binarySearch(rect, start: (mid + 1), end: end)
            } else {
                return binarySearch(rect, start: start, end: (mid - 1))
            }
        }
    }
}


// MARK: - Overriden
extension SMMosaicLayout {

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }

        let itemsNumber: Int = collectionView.numberOfItems(inSection: 0)

        if itemsNumber != cachedAttributes.count {

            computeCellsAttributes()
        }

        footerAttributes.frame = footerFrame
    }

    override var collectionViewContentSize: CGSize {

        let additionalHeight = layoutInsets.top + layoutInsets.bottom + footerHeight

        return contentBounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: -additionalHeight, right: 0)).size
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        collectionView?.bounds.size != newBounds.size
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        if indexPath.item < cachedAttributes.count {

            return cachedAttributes[indexPath.item]
        } else {

            computeCellsAttributes()
            footerAttributes.frame = footerFrame

            return cachedAttributes[indexPath.item]
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var attributesArray: [UICollectionViewLayoutAttributes] = []

        if footerAttributes.frame.intersects(rect) {

            attributesArray.append(footerAttributes)
        }

        guard let lastIndex: Int = cachedAttributes.indices.last,
            let firstMatchIndex: Int = binarySearch(rect, start: 0, end: lastIndex) else { return attributesArray }

        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY - 200 else { break }
            attributesArray.append(attributes)
        }

        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY + 200 else { break }
            attributesArray.append(attributes)
        }

        return attributesArray
    }

    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String, at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {

        guard elementKind == UICollectionView.elementKindSectionFooter else { return nil }

        return footerAttributes
    }
}
