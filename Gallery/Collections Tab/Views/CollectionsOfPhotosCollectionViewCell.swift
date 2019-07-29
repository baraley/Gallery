//
//  CollectionsOfPhotosCollectionViewCell.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/22/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class CollectionsOfPhotosCollectionViewCell: ImageCollectionViewCell {
	
	@IBOutlet var titleLabel: UILabel!
}

extension CollectionsOfPhotosCollectionViewCell: ConfigurableCell {
	
	func configure(_ item: PhotoCollection) {
		titleLabel.text = item.title
	}
}
