//
//  PhotoViewContorller.swift
//  Gallery
//
//  Created by Alexander Baraley on 12/25/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotoViewContorller: UIViewController {
	
    @IBOutlet var photoScrollView: ImageScrollView!
	@IBOutlet private var imageLoadingView: UIActivityIndicatorView!
	
    var photo: Photo!
	var networkRequestPerformer: NetworkService?
	
	private var photoImage: UIImage? {
		didSet{ photoScrollView.image = photoImage }
	}
	
	private var lastZoomLocation: CGPoint?
	
	private var photoBackground: PhotoBackground = .light {
		didSet { photoBackgroundDidChange() }
	}
	
	// MARK: - Life cycle -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		photoScrollView.tapGesturesHandler = self
		photoScrollView.singleTapGestureRecognizer.require(
			toFail: photoScrollView.doubleTapGestureRecognizer
		)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		photoBackgroundDidChange()
		loadPhoto()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		networkRequestPerformer?.cancel(ImageRequest(url: photo.imageURL))
	}
	
	override func viewWillTransition(to size: CGSize,
									 with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		saveLastZoomLocation()
		
		coordinator.animate(alongsideTransition: { [weak self] _ in
			self?.layoutScrollViewContent(for: size)
		}, completion: nil)
	}
}

// MARK: - Helpers
private extension PhotoViewContorller {
	
	enum PhotoBackground: Equatable {
		case light, dark
		
		mutating func toggle() {
			self = self == .light ? .dark : .light
		}
	}
	
	// MARK: - Image loading -
	
	func loadPhoto() {
		imageLoadingView?.isHidden = false
		
		let request = ImageRequest(url: photo.imageURL)
		
		networkRequestPerformer?.performRequest(request) { [weak self]  (result) in
			DispatchQueue.main.async {
				self?.handleLoadingResult(result)
				self?.imageLoadingView?.isHidden = true
			}
		}
	}
	
	func handleLoadingResult(_ result: Result<UIImage, RequestError>) {
		switch result {
		case .success(let image):
			photoImage = image
			layoutScrollViewContent(for: view.frame.size)
			
		case .failure(let error):
			switch error {
			case .noInternet, .limitExceeded:
				showAlertWith(error.localizedDescription)
			default:
				print(error.localizedDescription)
			}
		}
	}
	
	// MARK: - Background layout -
	
	func updateBars() {
        if let navBarIsHidden = navigationController?.isNavigationBarHidden,
            let toolBarIsHidden = navigationController?.isToolbarHidden {
            
            navigationController?.setNavigationBarHidden(!navBarIsHidden, animated: true)
            navigationController?.setToolbarHidden(!toolBarIsHidden, animated: true)
			
			photoBackground.toggle()
			
			UIView.animate(withDuration: 0.35) {
				self.photoBackgroundDidChange()
			}
            setNeedsStatusBarAppearanceUpdate()
        }
    }
	
	func photoBackgroundDidChange() {
		switch photoBackground {
		case .light:
			view.backgroundColor = .white
			imageLoadingView.color = .black
			
		case .dark:
			view.backgroundColor = .black
			imageLoadingView.color = .white
		}
    }
	
	// MARK: - Scroll view layout -
	
	func layoutScrollViewContent(for size: CGSize) {
		setupMinZoomScale(for: size)
		photoScrollView.updateConstraints(for: size)
		
		if let zoomLocation = lastZoomLocation {
			photoScrollView.zoom(to: rectToZoom(in: zoomLocation), animated: false)
		}
	}
	
	func setupMinZoomScale(for size: CGSize) {
		guard let image = photoImage else  { return }
		
		let xScale = size.width / image.size.width
		let yScale = size.height / image.size.height
		
		let minScale = min(xScale, yScale)
		
		photoScrollView.minimumZoomScale = minScale
		photoScrollView.zoomScale = minScale
	}
	
	func rectToZoom(in zoomLocation: CGPoint) -> CGRect {
		let viewSize = view.frame.size
		
		let photoImageInsets = photoScrollView.constraintsInsets
		
		let xOrigin = zoomLocation.x - (viewSize.width / 2) - photoImageInsets.left
		let yOrigin = zoomLocation.y - (viewSize.height / 2) - photoImageInsets.top
		
		return CGRect(x: xOrigin, y: yOrigin, width: viewSize.width, height: viewSize.height)
	}
	
	func saveLastZoomLocation() {
		if photoScrollView.zoomScale != photoScrollView.minimumZoomScale {
			lastZoomLocation = photoScrollView.currentZoomCenter
		} else {
			lastZoomLocation = nil
		}
	}
}

extension PhotoViewContorller: ImageScrollViewGesturesHandler {
    
	func imageScrollView(_ imageScrollView: ImageScrollView, singleTapDidHappenIn location: CGPoint) {
		updateBars()
	}
	
	func imageScrollView(_ imageScrollView: ImageScrollView, doubleTapDidHappenIn location: CGPoint) {
		
		if photoScrollView.zoomScale == photoScrollView.minimumZoomScale {
			photoScrollView.zoom(to: rectToZoom(in: location), animated: true)
		} else {
			photoScrollView.setZoomScale(photoScrollView.minimumZoomScale, animated: true)
		}
	}
}
