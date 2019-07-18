//
//  ImageScrollView.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/17/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

protocol ImageScrollViewGesturesHandler: AnyObject {
	func imageScrollView(_ imageScrollView: ImageScrollView, singleTapDidHappenIn location: CGPoint)
	func imageScrollView(_ imageScrollView: ImageScrollView, doubleTapDidHappenIn location: CGPoint)
}

class ImageScrollView: UIScrollView {
	
	var image: UIImage? {
		didSet{ imageView.image = image }
	}
	
	weak var tapGesturesHandler: ImageScrollViewGesturesHandler?
	
	@IBOutlet var singleTapGestureRecognizer: UITapGestureRecognizer!
	@IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
	
	@IBOutlet private var imageView: UIImageView!
	
	@IBOutlet private var traillingConstraint: NSLayoutConstraint!
	@IBOutlet private var bottomConstraint: NSLayoutConstraint!
	@IBOutlet private var leadingConstraint: NSLayoutConstraint!
	@IBOutlet private var topConstraint: NSLayoutConstraint!
	
	@IBAction private func singleTapAction(_ sender: UITapGestureRecognizer) {
		guard sender.state == UIGestureRecognizer.State.ended else { return }
		
		tapGesturesHandler?.imageScrollView(self, singleTapDidHappenIn: sender.location(in: self))
	}
	
	@IBAction private func doubleTapAction(_ sender: UITapGestureRecognizer) {
		guard sender.state == UIGestureRecognizer.State.ended else { return }
		
		tapGesturesHandler?.imageScrollView(self, doubleTapDidHappenIn: sender.location(in: imageView))
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		delegate = self
	}
	
	var constraintsInsets: UIEdgeInsets {
		return UIEdgeInsets(top: topConstraint.constant, left: leadingConstraint.constant,
							bottom: bottomConstraint.constant, right: traillingConstraint.constant)
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
		traillingConstraint.constant = xOffset
		
		layoutIfNeeded()
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
