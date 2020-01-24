//
//  RoundedImageCollectionViewCell.swift
//  Gallery
//
//  Created by Alexander Baraley on 24.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class RoundedImageCollectionViewCell: ImageCollectionViewCell {

	var cornerRadius: CGFloat = 0.0 {
		didSet {
			cornerRadiusDidChange()
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		setupCorners()
		setupShadows()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		updateShadowPath()
	}
}

private extension RoundedImageCollectionViewCell {

	func cornerRadiusDidChange() {
		setupCorners()
		setupShadows()
	}

	func setupCorners() {
		layer.cornerRadius = cornerRadius
		layer.masksToBounds = false

		contentView.layer.cornerRadius = cornerRadius
		contentView.layer.masksToBounds = true
	}

	func setupShadows() {
		layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
		layer.shadowRadius = 3.0
		layer.shadowOpacity = 0.5
		updateShadowPath()
	}

	func updateShadowPath() {
		let rect = CGRect(origin: CGPoint.zero, size: bounds.size)
		layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
	}
}
