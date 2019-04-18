//
//  CrossDissolveTransitionAnimator.swift
//  SwiftCustomTransitions
//
//  Created by Alexander Baraley on 8/13/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit


class CrossDissolveTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	
	let duration: TimeInterval = 0.35
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return duration
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		let containerView = transitionContext.containerView
		
		let toView = transitionContext.view(forKey: .to)
		let fromView = transitionContext.view(forKey: .from)
		
		containerView.addSubview(toView!)
		
		toView?.alpha = 0.0
		fromView?.alpha = 1.0
		
		UIView.animate(withDuration: duration, animations: {
			toView?.alpha = 1.0
			fromView?.alpha = 0.0
		}) { (finished) in
			let wasCanceled = transitionContext.transitionWasCancelled
			transitionContext.completeTransition(!wasCanceled)
		}
	}
}
