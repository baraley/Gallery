//
//  PhotosCollectionViewController.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/19/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UICollectionViewController, SegueHandlerType {
	
	var photoStore: PhotoStore? { didSet { photoStoreDidChange() } }
	var networkRequestPerformer: NetworkService?
    
	// MARK: - Private properties
	
	private var errorMessageWasShown = false
    
    private weak var activityIndicatorView: UIActivityIndicatorView?
	
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .darkGray
        refreshControl.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
        return refreshControl
    }()
    
    // MARK: - Life cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		scrollToSelectedPhoto(animated: false)
	}
	
	override func viewWillTransition(to size: CGSize,
									 with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: { (_) in
            self.collectionViewLayout.invalidateLayout()
		})
	}

    // MARK: - Navigation
	
	enum SegueIdentifier: String {
		case photoPageViewController
	}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard case .photoPageViewController = segueIdentifier(for: segue) else { return  }
		
        let photoPageViewController = segue.destination as! PhotoPageViewController
        photoPageViewController.photoStore = photoStore
		photoPageViewController.networkRequestPerformer = networkRequestPerformer
    }
}

// MARK: - Helpers
private extension PhotosCollectionViewController {
	
	func setup() {
		collectionView?.refreshControl = refreshControl
		
		collectionView?.register(CollectionViewLoadingFooter.self,
								 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
								 withReuseIdentifier: CollectionViewLoadingFooter.identifier)
	}
	
	func photoStoreDidChange() {
		guard let photoStore = photoStore,
			let layout = collectionView?.collectionViewLayout as? PinterestCollectionViewLayout
		else { refreshPhotos(); return }
		
		errorMessageWasShown = false
		layout.dataSource = photoStore
		photoStore.delegate = self
		layout.reset()
		collectionView?.reloadData()
	}
	
	func scrollToSelectedPhoto(animated: Bool) {
		if let index = photoStore?.selectedPhotoIndex {
			let indexPath = IndexPath(item: index, section: 0)
			collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
		}
	}
	
	@objc func refreshPhotos() {
		if let layout = collectionView?.collectionViewLayout as? PinterestCollectionViewLayout {
			layout.reset()
		}
		photoStore?.reloadPhotos()
		collectionView?.reloadData()
	}
	
	func insertItems(_ numberOfItems: Int, at index: Int) {
		guard numberOfItems > 0 else { return }
		
		var indexPaths: [IndexPath] = []
		
		for i in index..<index + numberOfItems {
			indexPaths.append(IndexPath(item: i, section: 0))
		}
		collectionView?.insertItems(at: indexPaths)
	}
	
	func handleThumbLoading(ofPhotoAt indexPath: IndexPath,
							with result: Result<UIImage, RequestError>) {
		switch result {
		case .success(let thumb):
			let cell = collectionView?.cellForItem(at: indexPath) as? PhotoCollectionViewCell
			cell?.imageView.image = thumb
			
		case .failure(let error):
			handle(error)
		}
	}
	
	func handle(_ error: RequestError) {
		switch error {
		case .noInternet, .limitExceeded:
			if errorMessageWasShown == false {
				errorMessageWasShown = true
				showAlertWith(error.localizedDescription)
			}
		default:
			print(error.localizedDescription)
		}
	}
}

// MARK: - UICollectionViewDataSource
extension PhotosCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView,
								 numberOfItemsInSection section: Int) -> Int {
		return photoStore?.numberOfPhotos ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView,
								 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(indexPath: indexPath) as PhotoCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
		
        let view = collectionView
            .dequeueSupplementaryView(of: kind, at: indexPath) as CollectionViewLoadingFooter
        return view
    }
}

// MARK: - UICollectionViewDelegate
extension PhotosCollectionViewController {
	
    override func collectionView(_ collectionView: UICollectionView,
								 willDisplay cell: UICollectionViewCell,
								 forItemAt indexPath: IndexPath) {
		 
		if let photo = photoStore?.photoAt(indexPath.row) {
			
			let imageRequest = ImageRequest(url: photo.thumbURL)
			
			networkRequestPerformer?.performRequest(imageRequest) { [weak self] (result) in
				DispatchQueue.main.async {
					self?.handleThumbLoading(ofPhotoAt: indexPath, with: result)
				}
			}
		}
		
    }
	
	override func collectionView(_ collectionView: UICollectionView,
								 didSelectItemAt indexPath: IndexPath) {
		photoStore?.selectedPhotoIndex = indexPath.item
	}
    
    override func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
		
		if let photo = photoStore?.photoAt(indexPath.item) {
			let imageRequest = ImageRequest(url: photo.thumbURL)
			networkRequestPerformer?.cancel(imageRequest)
		}
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String, at indexPath: IndexPath) {
        
        guard let footer = view as? CollectionViewLoadingFooter else { return }
        activityIndicatorView = footer.activityIndicator
		
		photoStore?.loadPhotos()
    }
}

// MARK: - PhotoStoreDelegate -
extension PhotosCollectionViewController: PhotoStoreDelegate {
	
	func photoStoreDidStartLoading(_ store: PhotoStore) {
		if !refreshControl.isRefreshing {
			activityIndicatorView?.startAnimating()
		}
	}
	
	func photoStore(_ store: PhotoStore, didInsertPhotos numberOfPhotos: Int, at index: Int) {
		
		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()
		errorMessageWasShown = false
		
		insertItems(numberOfPhotos, at: index)
	}
		
	func photoStore(_ store: PhotoStore, loadingFailedWithError error: RequestError) {
		
		refreshControl.endRefreshing()
		activityIndicatorView?.stopAnimating()
		handle(error)
	}
}
