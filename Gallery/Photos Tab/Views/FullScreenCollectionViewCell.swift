//
//  FullScreenCollectionViewCell.swift
//  Gallery
//
//  Created by Alexander Baraley on 14.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

var count = 0

class FullScreenCollectionViewCell: UICollectionViewCell {

	// MARK: - Initialization

	private let scrollView = UIScrollView(frame: .zero)
	private let imageView = UIImageView(image: nil)
	private let loadingView = UIActivityIndicatorView(style: .whiteLarge)

	override init(frame: CGRect) {
		super.init(frame: frame)

		initialSetup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overridden

	override func layoutSubviews() {
		super.layoutSubviews()

		scrollView.frame = contentView.bounds
		loadingView.center = contentView.center
		updateScrollView()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		scrollView.zoomScale = 1.0
		image = nil
	}

	// MARK: - Public

	var loadingViewColor: UIColor = .black {
		didSet {
			loadingView.color = loadingViewColor
		}
	}

	var image: UIImage? {
		get {
			imageView.image
		}
		set {
			imageView.image = newValue
			imageDidChange()
		}
	}
}

private extension FullScreenCollectionViewCell {

	func initialSetup() {
		imageView.contentMode = .scaleAspectFit

		setupLoadingView()
		setupScrollView()

		contentView.addSubview(scrollView)
		contentView.addSubview(loadingView)
	}

	func setupLoadingView() {
		loadingView.startAnimating()
		loadingView.color = loadingViewColor
	}

	func setupScrollView() {
		scrollView.delegate = self
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.addSubview(imageView)
	}

	func updateScrollView() {
		guard let image = imageView.image else { return }

		let widthScale = contentView.bounds.size.width / image.size.width
		let heightScale = contentView.bounds.size.height / image.size.height

		let minScale = min(widthScale, heightScale)

		scrollView.contentSize = contentView.bounds.size
		scrollView.minimumZoomScale = minScale
		scrollView.zoomScale = minScale

		if minScale == widthScale {
			let imageRelativeHeight = contentView.bounds.size.height - (image.size.height * minScale)
			let inset = imageRelativeHeight / 2

			scrollView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
		} else {
			let imageRelativeWidth = contentView.bounds.size.width - (image.size.width * minScale)
			let inset = imageRelativeWidth / 2

			scrollView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
		}
	}

	func imageDidChange() {
		if imageView.image == nil {
			loadingView.startAnimating()
		} else {
			loadingView.stopAnimating()
		}
		imageView.sizeToFit()
		setNeedsLayout()
	}
}

extension FullScreenCollectionViewCell: UIScrollViewDelegate {

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		imageView
	}
}
