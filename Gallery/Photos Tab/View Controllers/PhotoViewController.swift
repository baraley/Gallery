//
//  PhotoViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 12/25/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

	var photo: Photo!
	var networkService: NetworkService!
	var authenticationStateProvider: AuthenticationStateProvider!

	// MARK: - Outlets -

    @IBOutlet private var imageScrollView: ImageScrollView!
	@IBOutlet private var loadingView: UIActivityIndicatorView!

	@IBOutlet private var photoToolBar: UIToolbar!
	@IBOutlet private var sharePhotoButton: UIBarButtonItem!
	@IBOutlet private var likePhotoButton: UIBarButtonItem!

	// MARK: - Actions

	@IBAction private func likePhotoAction(_ sender: UIBarButtonItem) {
		toggleLikeOfPhoto()
	}

	@IBAction private func sharePhotoAction(_ sender: UIBarButtonItem) {
		sharePhoto()
	}

	// MARK: - Life cycle -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageScrollView.tapGesturesDelegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		updatePhotoBackgroundColor()
		loadImage()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

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

	func showError(_ error: RequestError) {
		switch error {
		case .noInternet, .limitExceeded:
			self.showAlertWith(error.localizedDescription)
		default:
			print(error.localizedDescription)
		}
	}

	// MARK: - Tool bar

	func updateToolBar() {
		likePhotoButton.isEnabled = authenticationStateProvider.isAuthenticated
		likePhotoButton.image = photo.isLiked ? #imageLiteral(resourceName: "unlike") : #imageLiteral(resourceName: "like")

		sharePhotoButton.isEnabled = imageScrollView.image != nil
	}

	func sharePhoto() {
		guard let image = imageScrollView.image?.jpegData(compressionQuality: 1.0) else { return }

		let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
		vc.popoverPresentationController?.barButtonItem = sharePhotoButton

		present(vc, animated: true, completion: nil)
	}

	// MARK: - Image loading

	func loadImage() {
		guard imageScrollView.image == nil else { return }

		loadingView?.startAnimating()

		let request = ImageRequest(url: photo.imageURL)

		networkService?.performRequest(request) { [weak self]  (result) in
			DispatchQueue.main.async {
				self?.handleLoadingResult(result)
				self?.loadingView?.stopAnimating()
			}
		}
	}

	func handleLoadingResult(_ result: Result<UIImage, RequestError>) {
		switch result {
		case .success(let image):
			imageScrollView.image = image
			imageScrollView.layoutContent(for: view.frame.size)
			updateToolBar()

		case .failure(let error):
			self.showError(error)
		}
	}

	// MARK: - Toggle Like

	func toggleLikeOfPhoto() {

		guard let accessToken = authenticationStateProvider.accessToken else { return }

		let toggleRequest = TogglePhotoLikeRequest(photo: photo, accessToken: accessToken)

		photoToolBar.items?.removeLast()
		photoToolBar.items?.append(UIBarButtonItem.loadingBarButtonItem)

		networkService.performRequest(toggleRequest) { [weak self] (result) in
			guard let self = self else { return }
			DispatchQueue.main.async {
				switch result {
				case .success(let photo):
					self.toolbarItems?.removeLast()
					self.toolbarItems?.append(self.likePhotoButton)
					self.photo = photo
					self.updateToolBar()

				case .failure(let error):
					self.showError(error)
				}
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
