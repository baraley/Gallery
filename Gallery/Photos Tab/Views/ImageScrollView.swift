//
//  ImageScrollView.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/17/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

protocol ImageScrollViewGesturesDelegate: AnyObject {
	func imageScrollViewSingleTapDidHappen(_ imageScrollView: ImageScrollView)
	func imageScrollViewDoubleTapDidHappen(_ imageScrollView: ImageScrollView)
}

class ImageScrollView: UIScrollView {

	// MARK: - Initialization

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		delegate = self
		setupTapGestures()
	}

	// MARK: - Properties
	
	var image: UIImage? {
		didSet{
			imageView.image = image
		}
	}
	
	weak var tapGesturesDelegate: ImageScrollViewGesturesDelegate?

	private var constraintsInsets: UIEdgeInsets {
		return UIEdgeInsets(top: topConstraint.constant, left: leadingConstraint.constant,
							bottom: bottomConstraint.constant, right: trailingConstraint.constant)
	}

	// MARK: - Outlets
	
	@IBOutlet private var imageView: UIImageView!
	
	@IBOutlet private var trailingConstraint: NSLayoutConstraint!
	@IBOutlet private var bottomConstraint: NSLayoutConstraint!
	@IBOutlet private var leadingConstraint: NSLayoutConstraint!
	@IBOutlet private var topConstraint: NSLayoutConstraint!

	// MARK: - Actions
	
	@objc private func singleTapAction(_ sender: UITapGestureRecognizer) {
		guard sender.state == UIGestureRecognizer.State.ended else { return }
		
		tapGesturesDelegate?.imageScrollViewSingleTapDidHappen(self)
	}
	
	@objc private func doubleTapAction(_ sender: UITapGestureRecognizer) {
		guard sender.state == UIGestureRecognizer.State.ended else { return }

		let location = sender.location(in: imageView)

		if zoomScale == minimumZoomScale {
			zoom(to: rectToZoom(in: location), animated: true)
		} else {
			setZoomScale(minimumZoomScale, animated: true)
		}
		
		tapGesturesDelegate?.imageScrollViewDoubleTapDidHappen(self)
	}

	// MARK: - Public

	func layoutContent(for size: CGSize) {

		setupMinZoomScale(for: size)
		updateConstraints(for: size)
	}
}

// MARK: - Private
private extension ImageScrollView {

	func setupTapGestures() {
		let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
		let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))

		doubleTapGestureRecognizer.numberOfTapsRequired = 2
		singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)

		addGestureRecognizer(singleTapGestureRecognizer)
		addGestureRecognizer(doubleTapGestureRecognizer)
	}

	func setupMinZoomScale(for size: CGSize) {
		guard let image = image else  { return }

		let xScale = size.width / image.size.width
		let yScale = size.height / image.size.height

		let minScale = min(xScale, yScale)

		minimumZoomScale = minScale
		zoomScale = minScale
	}

	func updateConstraints(for size: CGSize) {
		let yOffset = max(0, (size.height - imageView.frame.height) / 2)
		topConstraint.constant = yOffset
		bottomConstraint.constant = yOffset

		let xOffset = max(0, (size.width - imageView.frame.width) / 2)
		leadingConstraint.constant = xOffset
		trailingConstraint.constant = xOffset

		layoutIfNeeded()
	}

	func rectToZoom(in zoomLocation: CGPoint) -> CGRect {
		let viewSize = frame.size

		let xOrigin = zoomLocation.x - (viewSize.width / 2) - constraintsInsets.left
		let yOrigin = zoomLocation.y - (viewSize.height / 2) - constraintsInsets.top

		return CGRect(x: xOrigin, y: yOrigin, width: viewSize.width, height: viewSize.height)
	}
}

// MARK: - UIScrollViewDelegate
extension ImageScrollView: UIScrollViewDelegate {
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		updateConstraints(for: frame.size)
	}
}

extension ImageScrollViewGesturesDelegate {

	func imageScrollViewSingleTapDidHappen(_ imageScrollView: ImageScrollView) {}
	func imageScrollViewDoubleTapDidHappen(_ imageScrollView: ImageScrollView) {}
}
