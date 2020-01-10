//
//  PhotoPageViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/2/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

protocol PhotoPageDataSource: AnyObject {
	var selectedPhotoIndex: Int? { get set }
	var numberOfPhotos: Int { get }
	
	func photoAt(_ index: Int) -> Photo?
	func indexOf(_ photo: Photo) -> Int?
	func loadMorePhoto()
}

extension PhotoPageDataSource {

	var selectedPhoto: Photo? {
		guard let index = selectedPhotoIndex else { return nil }
		return photoAt(index)
	}

	func selectPhoto(_ photo: Photo) {
		let index = indexOf(photo)

		selectedPhotoIndex = index
	}
}

class PhotoPageViewController: UIPageViewController {
	
    var photoPageDataSource: PhotoPageDataSource!
	var networkRequestPerformer: NetworkService!
	var authenticationStateProvider: AuthenticationStateProvider!

	private var lastUsedPhotoIndex: Int = 0
		
	// MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        dataSource = self
        delegate = self
		
		setupFirstViewController()
    }
}

// MARK: - Helpers
private extension PhotoPageViewController {

	var currentPhotoIndex: Int {
		get {
			photoPageDataSource.selectedPhotoIndex ?? 0
		}
		set {
			photoPageDataSource.selectedPhotoIndex = newValue
		}
	}

	var nextPhotoIndex: Int? {
		let expectedIndex = currentPhotoIndex + 1
		return expectedIndex < photoPageDataSource.numberOfPhotos ? expectedIndex : nil
	}

	var previousPhotoIndex: Int? {
		let expectedIndex = currentPhotoIndex - 1
		return expectedIndex < 0 ? nil : expectedIndex
	}
	
	func setupFirstViewController() {
		guard let photo = photoPageDataSource.photoAt(currentPhotoIndex) else {
			return
		}

		if currentPhotoIndex >= photoPageDataSource.numberOfPhotos - 5 {
			photoPageDataSource.loadMorePhoto()
		}

		setViewControllers([photoViewControllerWith(photo)], direction: .forward, animated: false, completion: nil)
	}

	func photoViewControllerWith(_ photo: Photo) -> PhotoViewController {

		let photoViewController = UIStoryboard(storyboard: .main).instantiateViewController() as PhotoViewController

		photoViewController.photo = photo
		photoViewController.networkService = networkRequestPerformer
		photoViewController.authenticationStateProvider = authenticationStateProvider

		return photoViewController
	}
}

// MARK: - UIPageViewControllerDataSource
extension PhotoPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index = previousPhotoIndex, let photo = photoPageDataSource.photoAt(index) else {
			return nil
		}
        lastUsedPhotoIndex = index
        return photoViewControllerWith(photo)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		guard let index = nextPhotoIndex, let photo = photoPageDataSource.photoAt(index) else {
			return nil
		}

		if index == photoPageDataSource.numberOfPhotos - 5 {
			photoPageDataSource.loadMorePhoto()
		}
		lastUsedPhotoIndex = index
        return photoViewControllerWith(photo)
    }
}

// MARK: - UIPageViewControllerDelegate
extension PhotoPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed else { return }
		
		photoPageDataSource.selectedPhotoIndex = lastUsedPhotoIndex
    }
}

extension PhotoPageViewController {
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .none }
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? false
    }
}

