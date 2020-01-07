//
//  PhotoPageViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/2/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

protocol PhotoPageDataSource {
	var selectedPhotoIndex: Int? { get set }
	var numberOfPhotos: Int { get }
	
	func photoAt(_ index: Int) -> Photo?
	func indexOf(_ photo: Photo) -> Int?
	func loadMorePhoto()
}

protocol PhotoLikesToggle {
	var isLikeTogglingAvailable: Bool { get }
	
	func toggleLikeOfPhoto(
		at index: Int, with completionHandler: @escaping (Result<Photo, RequestError>) -> Void
	)
}

class PhotoPageViewController: UIPageViewController {
	
    var photoPageDataSource: (PhotoPageDataSource & PhotoLikesToggle)!
	var networkRequestPerformer: NetworkService!
	
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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		navigationController?.setToolbarHidden(false, animated: true)
		updateLikeButton()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setToolbarHidden(true, animated: false)
    }
}

// MARK: - Helpers
private extension PhotoPageViewController {
	
	func setupFirstViewController() {
		guard let selectedPhotoIndex = photoPageDataSource.selectedPhotoIndex,
			let photo = photoPageDataSource.photoAt(selectedPhotoIndex) else { return }
		
		if selectedPhotoIndex > photoPageDataSource.numberOfPhotos - 5 {
			photoPageDataSource.loadMorePhoto()
		}
		
		setViewControllers([photoViewControllerWith(photo)],
						   direction: .forward, animated: false, completion: nil)
	}
	
	func photoViewControllerWith(_ photo: Photo) -> PhotoViewController {
		
		let photoViewController = storyboard?
			.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
		
		photoViewController.photo = photo
		photoViewController.networkService = networkRequestPerformer
		
		return photoViewController
	}
    
    func updateLikeButton() {
        guard photoPageDataSource.isLikeTogglingAvailable,
            let selectedPhotoIndex = photoPageDataSource.selectedPhotoIndex,
            let photo = photoPageDataSource.photoAt(selectedPhotoIndex)
            else { return }
        
        
        likePhotoButton.isEnabled = true
        likePhotoButton.image = photo.isLiked ? #imageLiteral(resourceName: "unlike") : #imageLiteral(resourceName: "like")
    }
	
	func toggleLikeOfPhoto() {
		
		guard let selectedPhotoIndex = photoPageDataSource.selectedPhotoIndex else { return }
		
		toolbarItems?.removeLast()
		toolbarItems?.append(UIBarButtonItem.loadingBarButtonItem)
		
		photoPageDataSource.toggleLikeOfPhoto(at: selectedPhotoIndex) { [weak self] (result) in
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
        guard let photoController = viewControllers?.first as? PhotoViewController,
            let image = photoController.imageScrollView.image?.jpegData(compressionQuality: 1.0)
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
        
        guard let selectedPhotoIndex = photoPageDataSource.selectedPhotoIndex,
			let photo = photoPageDataSource.photoAt(selectedPhotoIndex - 1)
		else { return nil }
		
        
        return photoViewControllerWith(photo)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		guard let selectedPhotoIndex = photoPageDataSource.selectedPhotoIndex,
		let photo = photoPageDataSource.photoAt(selectedPhotoIndex + 1)
		else { return nil }
		
		if selectedPhotoIndex == photoPageDataSource.numberOfPhotos - 5 {
			photoPageDataSource.loadMorePhoto()
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
            let viewController = viewControllers?.first as? PhotoViewController
        else { return }
		
		if let index = photoPageDataSource.indexOf(viewController.photo) {
			photoPageDataSource.selectedPhotoIndex = index
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
