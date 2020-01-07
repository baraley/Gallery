//
//  ImageScrollView.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/17/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

protocol ImageScrollViewGesturesDelegate: AnyObject {
	func imageScrollView(_ imageScrollView: ImageScrollView, singleTapDidHappenAt point: CGPoint)
	func imageScrollView(_ imageScrollView: ImageScrollView, doubleTapDidHappenAt point: CGPoint)
}

class ImageScrollView: UIScrollView {

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		delegate = self
		configureTapGestures()
	}
	
	var image: UIImage? {
		didSet{
			imageView.image = image
		}
	}
	
	weak var tapGesturesDelegate: ImageScrollViewGesturesDelegate?
	
	@IBOutlet private var imageView: UIImageView!
	
	@IBOutlet private var trailingConstraint: NSLayoutConstraint!
	@IBOutlet private var bottomConstraint: NSLayoutConstraint!
	@IBOutlet private var leadingConstraint: NSLayoutConstraint!
	@IBOutlet private var topConstraint: NSLayoutConstraint!
	
	@objc private func singleTapAction(_ sender: UITapGestureRecognizer) {
		guard sender.state == UIGestureRecognizer.State.ended else { return }
		
		tapGesturesDelegate?.imageScrollView(self, singleTapDidHappenAt: sender.location(in: self))
	}
	
	@objc private func doubleTapAction(_ sender: UITapGestureRecognizer) {
		guard sender.state == UIGestureRecognizer.State.ended else { return }
		
		tapGesturesDelegate?.imageScrollView(self, doubleTapDidHappenAt: sender.location(in: imageView))
	}
	
	var constraintsInsets: UIEdgeInsets {
		return UIEdgeInsets(top: topConstraint.constant, left: leadingConstraint.constant,
							bottom: bottomConstraint.constant, right: trailingConstraint.constant)
	}
	
	var currentZoomCenter: CGPoint {
		return imageView.convert(center, from: self.superview)
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

	private func configureTapGestures() {
		let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
		let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))

		doubleTapGestureRecognizer.numberOfTapsRequired = 2
		singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)

		addGestureRecognizer(singleTapGestureRecognizer)
		addGestureRecognizer(doubleTapGestureRecognizer)
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
