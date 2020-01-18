//
//  FullScreenCollectionViewCell.swift
//  Gallery
//
//  Created by Alexander Baraley on 14.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class FullScreenCollectionViewCell: UICollectionViewCell {

	var singleTapGestureHandler: (() -> Void)?

	// MARK: - Initialization

	let imageView = UIImageView(image: nil)
	private let scrollView = UIScrollView(frame: .zero)
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
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		scrollView.zoomScale = 1.0
		showImage(nil)
	}

	// MARK: - Public

	var loadingViewColor: UIColor = .black {
		didSet {
			loadingView.color = loadingViewColor
		}
	}

	func showImage(_ image: UIImage?) {

		imageView.image = image

		if image == nil {
			loadingView.startAnimating()
		} else {
			loadingView.stopAnimating()
			imageView.sizeToFit()
			updateScrollViewZoomScales()
		}
	}

	// MARK: - Updates

	func updateScrollViewZoomScales() {
		guard let image = imageView.image else { return }

		let widthScale = contentView.bounds.size.width / image.size.width
		let heightScale = contentView.bounds.size.height / image.size.height

		let minScale = min(widthScale, heightScale)

		scrollView.minimumZoomScale = minScale
		scrollView.zoomScale = minScale
	}
}

// MARK: - Private
private extension FullScreenCollectionViewCell {

	// MARK: - Setups

	func initialSetup() {
		setupLoadingView()
		setupImageView()
		setupScrollView()
		setupGestureRecognizers()

		contentView.addSubview(scrollView)
		contentView.addSubview(loadingView)
	}

	func setupLoadingView() {
		loadingView.startAnimating()
		loadingView.color = loadingViewColor
	}

	func setupImageView() {
		imageView.contentMode = .scaleAspectFit
		imageView.isUserInteractionEnabled = true
	}

	func setupScrollView() {
		scrollView.delegate = self
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.addSubview(imageView)
	}

	func setupGestureRecognizers() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))

		tap.require(toFail: doubleTap)
		doubleTap.numberOfTapsRequired = 2

		imageView.addGestureRecognizer(doubleTap)
		scrollView.addGestureRecognizer(tap)
	}

	func setupScrollViewContentInset() {

		var hInset = (bounds.width - scrollView.contentSize.width) / 2
		var vInset = (bounds.height - scrollView.contentSize.height) / 2

		hInset = hInset > 0 ? hInset : 0
		vInset = vInset > 0 ? vInset : 0

		scrollView.contentInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
	}

	// MARK: - Gesture recognizers' actions

	@objc private func singleTapAction(_ sender: UITapGestureRecognizer) {
		guard sender.state == UIGestureRecognizer.State.ended else { return }

		singleTapGestureHandler?()
	}

	@objc private func doubleTapAction(_ sender: UITapGestureRecognizer) {

		let tapLocation = sender.location(in: imageView)

		if scrollView.zoomScale != scrollView.minimumZoomScale {
			scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
		} else {
			let xOrigin = tapLocation.x - (bounds.width / 2)
			let yOrigin = tapLocation.y - (bounds.height / 2)

			let zoomRect = CGRect(x: xOrigin, y: yOrigin, width: bounds.width, height: bounds.height)

			scrollView.zoom(to: zoomRect, animated: true)
		}
	}
}

// MARK: - UIScrollViewDelegate
extension FullScreenCollectionViewCell: UIScrollViewDelegate {

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		imageView
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		setupScrollViewContentInset()
	}
}
