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
	
	// MARK: - Life cycle -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageScrollView.tapGesturesDelegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updatePhotoBackgroundColor()
		loadPhoto()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		networkService?.cancel(ImageRequest(url: photo.imageURL))
	}
	
	override func viewWillTransition(to size: CGSize,
									 with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: { [weak self] _ in
			self?.imageScrollView.layoutContent(for: size)
		})
	}
}

// MARK: - Helpers
private extension PhotoViewController {
	
	func updatePhotoBackgroundColor() {
		guard let navigationController = navigationController else { return }

		let barsAreHidden = navigationController.isNavigationBarHidden && navigationController.isToolbarHidden

		parent?.view.backgroundColor = barsAreHidden ? .black : .white
		loadingView.color = barsAreHidden ? .white : .black
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
			imageScrollView.layoutContent(for: view.frame.size)

		case .failure(let error):
			switch error {
			case .noInternet, .limitExceeded:
				showAlertWith(error.localizedDescription)
			default:
				print(error.localizedDescription)
			}
		}
	}
}

extension PhotoViewController: ImageScrollViewGesturesDelegate {
    
	func imageScrollViewSingleTapDidHappen(_ imageScrollView: ImageScrollView) {
		if let isNavBarHidden = navigationController?.isNavigationBarHidden,
            let isToolBarHidden = navigationController?.isToolbarHidden {

			UIView.animate(withDuration: 0.35) {
				self.navigationController?.isNavigationBarHidden = !isNavBarHidden
				self.navigationController?.isToolbarHidden = !isToolBarHidden

				self.updatePhotoBackgroundColor()
			}
			setNeedsStatusBarAppearanceUpdate()
        }
	}
}
