//
//  PhotoPageViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/2/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotoPageViewController: UIPageViewController {
    
    @IBOutlet private var likePhotoButton: UIBarButtonItem!
    
    var photoStore: PhotoStore!
	
	var imageLoader: ImageLoader?
	
	// MARK: - Actions
		
	@IBAction private func likePhotoAction(_ sender: UIBarButtonItem) {
        toggleLikeOfSelectedPhoto()
	}
		
	// MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        dataSource = self
        delegate = self
		
		setupFirstViewController()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateLikeButton()
	}
}

// MARK: - Helpers
private extension PhotoPageViewController {
	
	func setupFirstViewController() {
		guard let selectedPhotoIndex = photoStore.selectedPhotoIndex,
			let photo = photoStore.photoAt(selectedPhotoIndex) else { return }
		
		setViewControllers([photoViewControllerWith(photo)],
						   direction: .forward, animated: false, completion: nil)
	}
	
	func photoViewControllerWith(_ photo: Photo) -> PhotoViewContorller {
		
		let photoViewController = storyboard?
			.instantiateViewController(withIdentifier: "PhotoViewContorller") as! PhotoViewContorller
		
		photoViewController.photo = photo
		photoViewController.imageLoader = imageLoader
		
		return photoViewController
	}
	
	func toggleLikeOfSelectedPhoto() {
		
		guard let selectedPhotoIndex = photoStore.selectedPhotoIndex else { return }
		
		navigationItem.setRightBarButton(UIBarButtonItem.loadingBarButtonItem, animated: true)
		
		photoStore.toggleLikeOfPhoto(at: selectedPhotoIndex) { [weak self] (errorString) in
			if let error = errorString {
				self?.showAlertWith(error)
			} else {
				self?.navigationItem.setRightBarButton(self?.likePhotoButton, animated: true)
				self?.updateLikeButton()
			}
		}
	}
	
	func updateLikeButton() {
		guard photoStore.isLikeTogglingAvailable,
			let selectedPhotoIndex = photoStore.selectedPhotoIndex,
			let photo = photoStore.photoAt(selectedPhotoIndex)
		else { return }
		
		
		likePhotoButton.isEnabled = true
		likePhotoButton.title = photo.isLiked ? "Unlike" : "Like"
	}
}

// MARK: - UIPageViewControllerDataSource
extension PhotoPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let selectedPhotoIndex = photoStore.selectedPhotoIndex,
			let photo = photoStore.photoAt(selectedPhotoIndex - 1)
		else { return nil }
		
        
        return photoViewControllerWith(photo)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		guard let selectedPhotoIndex = photoStore.selectedPhotoIndex,
		let photo = photoStore.photoAt(selectedPhotoIndex + 1)
		else { return nil }
		
        return photoViewControllerWith(photo)
    }
}

// MARK: - UIPageViewControllerDelegate
extension PhotoPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        guard completed,
            let viewController = viewControllers?.first as? PhotoViewContorller
        else { return }
		
		if let index = photoStore.indexOf(viewController.photo) {
			photoStore.selectedPhotoIndex = index
		}
		
		updateLikeButton()
    }
}

extension PhotoPageViewController {
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .none }
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? false
    }
}
