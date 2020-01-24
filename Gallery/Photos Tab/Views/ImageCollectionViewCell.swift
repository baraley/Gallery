//
//  ImageCollectionViewCell.swift
//  Gallery
//
//  Created by Alexander Baraley on 12/17/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell, CellWithImage {
    
	private var imageView = UIImageView(image: #imageLiteral(resourceName: "image placeholder"))

	var image: UIImage? {
		get {
			imageView.image
		}
		set {
			imageView.image = newValue
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		setupImageView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func prepareForReuse() {
		super.prepareForReuse()
		
        imageView.image = #imageLiteral(resourceName: "image placeholder")
	}

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
}
