//
//  FullScreenCollectionViewCell.swift
//  Gallery
//
//  Created by Alexander Baraley on 14.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class FullScreenCollectionViewCell: UICollectionViewCell {

	private let imageView = UIImageView(frame: .zero)
	private let loadingView = UIActivityIndicatorView(style: .whiteLarge)

	var loadingViewColor: UIColor = .black {
		didSet {
			loadingView.color = loadingViewColor
		}
	}
	var image: UIImage? {
		didSet {
			imageDidChange()
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		setupImageView()
		setupLoadingView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		image = nil
	}
}

private extension FullScreenCollectionViewCell {

	func setupLoadingView() {
		loadingView.startAnimating()
		loadingView.color = loadingViewColor
		loadingView.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(loadingView)

		NSLayoutConstraint.activate([
			loadingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			loadingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
		])
	}

	func setupImageView() {
		imageView.contentMode = .scaleAspectFit

		imageView.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(imageView)

		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
		])
	}

	func imageDidChange() {
		if image == nil {
			loadingView.startAnimating()
		} else {
			loadingView.stopAnimating()
		}
		imageView.image = image
	}
}
