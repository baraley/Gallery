//
//  PinterestLayoutFrameCalculator.swift
//  Gallery
//
//  Created by Alexander Baraley on 10/19/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import CoreGraphics

class PinterestLayoutFrameCalculator {

	// MARK: - Initialization
	
	let contentWidth: CGFloat
	private let cellSpacing: CGFloat
	private let numberOfColumns: Int
	
	init(contentWidth: CGFloat, cellSpacing: CGFloat, numberOfColumns: Int) {
		self.contentWidth = contentWidth
		self.cellSpacing = cellSpacing
		self.numberOfColumns = numberOfColumns
	}

	// MARK: - Public methods
	
	func frameForItem(with size: CGSize) -> CGRect {
		let origin = currentCellOrigin
		let frame = CGRect(origin: origin, size: size)
		
		addNewCellToLayout(with: frame)
		
		return frame.insetBy(dx: cellSpacing, dy: cellSpacing)
	}
	
	// MARK: - Private properties
	
	private(set) var contentHeight: CGFloat = 0
	
	private lazy var xOffset: [CGFloat] = {
		var offset: [CGFloat] = []
		for column in 0 ..< numberOfColumns {
			offset.append(CGFloat(column) * contentWidth / CGFloat(numberOfColumns))
		}
		return offset
	}()
	
	private lazy var yOffset: [CGFloat] = {
		return [CGFloat](repeating: 10, count: numberOfColumns)
	}()
	
	private var minYIndex: Int {
		if let minY = yOffset.min(), let index = yOffset.firstIndex(of: minY) {
			return index
		}
		return 0
	}
	
	private var currentCellOrigin: CGPoint {
		let origin = CGPoint(x: xOffset[minYIndex], y: yOffset[minYIndex])
		return origin
	}
	
	// MARK: - Private methods
	
	private func addNewCellToLayout(with frame: CGRect) {
		contentHeight = max(contentHeight, frame.maxY)
		yOffset[minYIndex] = yOffset[minYIndex] + frame.height
	}
}
