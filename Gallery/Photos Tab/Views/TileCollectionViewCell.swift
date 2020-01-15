//
//  TileCollectionViewCell.swift
//  Gallery
//
//  Created by Alexander Baraley on 12/17/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import UIKit

private let cornerRadius: CGFloat = 10

class TileCollectionViewCell: UICollectionViewCell {
    
	var imageView = UIImageView(image: #imageLiteral(resourceName: "image placeholder"))

	override init(frame: CGRect) {
		super.init(frame: frame)

		setupImageView()
		setupCorners()
		setupShadows()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func prepareForReuse() {
		super.prepareForReuse()
		
        imageView.image = #imageLiteral(resourceName: "image placeholder")
	}
	
	func setupShadowPath(for size: CGSize) {
		let rect = CGRect(origin: CGPoint.zero, size: size)
		layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
	}
}

private extension TileCollectionViewCell {

	func setupImageView() {

		imageView.contentMode = .scaleAspectFill

		imageView.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(imageView)

		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
		])
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
	}
}
