//
//  ImageCollectionViewCell.swift
//  Gallery
//
//  Created by Alexander Baraley on 12/17/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import UIKit

private let cornerRadius: CGFloat = 10

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupCorners()
		setupShadows()
	}
	
    override func prepareForReuse() {
		super.prepareForReuse()
		
        imageView.image = #imageLiteral(resourceName: "Placeholder")
	}
	
	private func setupCorners() {
		layer.cornerRadius = cornerRadius
		layer.masksToBounds = false
		
		contentView.layer.cornerRadius = cornerRadius
		contentView.layer.masksToBounds = true
	}
	
	private func setupShadows() {
		layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
		layer.shadowRadius = 3.0
		layer.shadowOpacity = 0.5
	}
	
	func setupShadowPath(for size: CGSize) {
		let rect = CGRect(origin: CGPoint.zero, size: size)
		layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
	}
}

class PhotoCollectionViewCell: ImageCollectionViewCell, ConfigurableCell {
	
	func configure(_ item: Photo) { }
}
