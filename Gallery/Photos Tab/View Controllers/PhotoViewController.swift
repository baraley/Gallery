//
//  PhotoViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 12/25/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
	
    @IBOutlet var imageScrollView: ImageScrollView!
	@IBOutlet private var loadingView: UIActivityIndicatorView!
	
    var photo: Photo!
	var networkService: NetworkService?
	
	private var photoImage: UIImage? {
		didSet{ imageScrollView.image = photoImage }
	}
	
	private var lastZoomLocation: CGPoint?
	
	private var photoBackground: PhotoBackground {
		if navigationController?.isNavigationBarHidden == true,
			navigationController?.isToolbarHidden == true,
			tabBarController?.tabBar.isHidden == true {
			return .dark
		}
		return .light
	}
	
	// MARK: - Life cycle -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageScrollView.tapGesturesDelegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		photoBackgroundDidChange()
		loadPhoto()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		networkService?.cancel(ImageRequest(url: photo.imageURL))
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
private extension PhotoViewController {
	
	enum PhotoBackground: Equatable {
		case light, dark
	}
	
	// MARK: - Image loading -
	
	func loadPhoto() {
		loadingView?.isHidden = false
		
		let request = ImageRequest(url: photo.imageURL)
		
		networkService?.performRequest(request) { [weak self]  (result) in
			DispatchQueue.main.async {
				self?.handleLoadingResult(result)
				self?.loadingView?.isHidden = true
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
			
			UIView.animate(withDuration: 0.35) {
				self.photoBackgroundDidChange()
			}
            setNeedsStatusBarAppearanceUpdate()
        }
    }
	
	func photoBackgroundDidChange() {
		switch photoBackground {
		case .light:
			parent?.view.backgroundColor = .white
			loadingView.color = .black
			
		case .dark:
			parent?.view.backgroundColor = .black
			loadingView.color = .white
		}
	}
	
	// MARK: - Scroll view layout -
	
	func layoutScrollViewContent(for size: CGSize) {
		setupMinZoomScale(for: size)
		imageScrollView.updateConstraints(for: size)
		
		if let zoomLocation = lastZoomLocation {
			imageScrollView.zoom(to: rectToZoom(in: zoomLocation), animated: false)
		}
	}
	
	func setupMinZoomScale(for size: CGSize) {
		guard let image = photoImage else  { return }
		
		let xScale = size.width / image.size.width
		let yScale = size.height / image.size.height
		
		let minScale = min(xScale, yScale)
		
		imageScrollView.minimumZoomScale = minScale
		imageScrollView.zoomScale = minScale
	}
	
	func rectToZoom(in zoomLocation: CGPoint) -> CGRect {
		let viewSize = view.frame.size
		
		let photoImageInsets = imageScrollView.constraintsInsets
		
		let xOrigin = zoomLocation.x - (viewSize.width / 2) - photoImageInsets.left
		let yOrigin = zoomLocation.y - (viewSize.height / 2) - photoImageInsets.top
		
		return CGRect(x: xOrigin, y: yOrigin, width: viewSize.width, height: viewSize.height)
	}
	
	func saveLastZoomLocation() {
		if imageScrollView.zoomScale != imageScrollView.minimumZoomScale {
			lastZoomLocation = imageScrollView.currentZoomCenter
		} else {
			lastZoomLocation = nil
		}
	}
}

extension PhotoViewController: ImageScrollViewGesturesDelegate {
    
	func imageScrollView(_ imageScrollView: ImageScrollView, singleTapDidHappenAt point: CGPoint) {
		updateBars()
	}
	
	func imageScrollView(_ imageScrollView: ImageScrollView, doubleTapDidHappenAt point: CGPoint) {
		
		if imageScrollView.zoomScale == imageScrollView.minimumZoomScale {
			imageScrollView.zoom(to: rectToZoom(in: point), animated: true)
		} else {
			imageScrollView.setZoomScale(imageScrollView.minimumZoomScale, animated: true)
		}
	}
}
