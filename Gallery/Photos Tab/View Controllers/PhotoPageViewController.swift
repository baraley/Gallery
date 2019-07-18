//
//  PhotoPageViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/2/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotoPageViewController: UIPageViewController {
    
    var photoStore: PhotoStore!
	
	var networkRequestPerformer: NetworkService?
	
	// MARK: - Outlets -
	
	@IBOutlet private var sharePhotoButton: UIBarButtonItem!
	@IBOutlet private var likePhotoButton: UIBarButtonItem!
	
	// MARK: - Actions
		
	@IBAction private func likePhotoAction(_ sender: UIBarButtonItem) {
        toggleLikeOfPhoto()
	}
    
    @IBAction private func sharePhotoAction(_ sender: UIBarButtonItem) {
        sharePhoto()
    }
		
	// MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        dataSource = self
        delegate = self
		
		setupFirstViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isToolbarHidden = true
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
		
		if selectedPhotoIndex > photoStore.numberOfPhotos - 5 {
			photoStore.loadPhotos()
		}
		
		setViewControllers([photoViewControllerWith(photo)],
						   direction: .forward, animated: false, completion: nil)
	}
	
	func photoViewControllerWith(_ photo: Photo) -> PhotoViewContorller {
		
		let photoViewController = storyboard?
			.instantiateViewController(withIdentifier: "PhotoViewContorller") as! PhotoViewContorller
		
		photoViewController.photo = photo
		photoViewController.networkRequestPerformer = networkRequestPerformer
		
		return photoViewController
	}
    
    func updateLikeButton() {
        guard photoStore.isLikeTogglingAvailable,
            let selectedPhotoIndex = photoStore.selectedPhotoIndex,
            let photo = photoStore.photoAt(selectedPhotoIndex)
            else { return }
        
        
        likePhotoButton.isEnabled = true
        likePhotoButton.image = photo.isLiked ? #imageLiteral(resourceName: "unlike") : #imageLiteral(resourceName: "like")
    }
	
	func toggleLikeOfPhoto() {
		
		guard let selectedPhotoIndex = photoStore.selectedPhotoIndex else { return }
		
		toolbarItems?.removeLast()
		toolbarItems?.append(UIBarButtonItem.loadingBarButtonItem)
		
		photoStore.toggleLikeOfPhoto(at: selectedPhotoIndex) { [weak self] (result) in
			guard let self = self else { return }
			
			switch result {
			case .success(_):
				self.toolbarItems?.removeLast()
				self.toolbarItems?.append(self.likePhotoButton)
				self.updateLikeButton()
				
			case .failure(let error):
				switch error {
				case .noInternet, .limitExceeded:
					self.showAlertWith(error.localizedDescription)
				default:
					print(error.localizedDescription)
				}
			}
		}
	}
    
    func sharePhoto() {
        guard let photoController = viewControllers?.first as? PhotoViewContorller,
            let image = photoController.photoScrollView.image?.jpegData(compressionQuality: 1.0)
        else { return }
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = sharePhotoButton
        
        present(vc, animated: true, completion: nil)
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
		
		if selectedPhotoIndex == photoStore.numberOfPhotos - 5 {
			photoStore.loadPhotos()
		}
		
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
