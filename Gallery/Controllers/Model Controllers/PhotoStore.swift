//
//  PhotoStore.swift
//  Gallery
//
//  Created by Alexander Baraley on 12/7/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

protocol PhotoStoreDelegate: AnyObject {
	func photoStoreDidStartLoading(_ store: PhotoStore)
	func photoStore(_ store: PhotoStore, didInsertPhotos number: Int, atIndex index: Int)
	func photoStore(_ store: PhotoStore, loadingFailedWithError error: RequestError)
}

class PhotoStore {
	
	weak var delegate: PhotoStoreDelegate?
	
	private let networkManager: NetworkRequestPerformer
	
	private let photosLoader: PhotosLoader
	private var photoLikesToggle: PhotoLikesToggle?
	
	init(networkManager: NetworkRequestPerformer, photoListRequest: PhotoListRequest) {
		self.networkManager = networkManager
		self.photosLoader = PhotosLoader(networkManager: networkManager,
										 photoListRequest: photoListRequest)
		
		if let accessToken = photoListRequest.accessToken {
			photoLikesToggle = PhotoLikesToggle(networkManager: networkManager, accessToken: accessToken)
		}
	}
	
	private var photos: [Photo] = [] { didSet { numberOfPhotos = photos.count } }
	
	private(set) var numberOfPhotos: Int = 0
	
	func photoAt(_ index: Int) -> Photo? {
		guard !photos.isEmpty, index >= 0 && index < numberOfPhotos else { return nil }
		
		if index > numberOfPhotos - 5 {
            loadPhotos()
        }
		
		return photos[index]
	}
	
	func indexOf(_ photo: Photo) -> Int? {
		return photos.firstIndex(of: photo)
	}
	
	var selectedPhotoIndex: Int?
		
	func reloadPhotos() {
		photosLoader.currentPage = 1
		photos.removeAll()
		loadPhotos()
	}
	
	// MARK: - Like -
	
	var isLikeTogglingAvailable: Bool {
		return photoLikesToggle != nil
	}
	
	func toggleLikeOfPhoto(at index: Int, completionHandler: @escaping (RequestError?) -> Void ) {
		guard photoLikesToggle != nil else { return }
		
		let photo = photos[index]
		
		photoLikesToggle?.toggleLike(of: photo, completionHandler: { [weak self] (result) in
			DispatchQueue.main.async {
				switch result {
				case let .success(toggledPhoto):
					self?.photos[index] = toggledPhoto
					completionHandler(nil)
					
				case let .failure(error):
					completionHandler(error)
				}
			}
		})
	}
}

// MARK: - Private
private extension PhotoStore {
	
	func loadPhotos() {
		if photosLoader.totalPages != 0, photosLoader.currentPage > photosLoader.totalPages { return }
		
		delegate?.photoStoreDidStartLoading(self)
		
		photosLoader.loadPhotos { [weak self] (result) in
			guard let self = self else { return }
			
			DispatchQueue.main.async {
				switch result {
				case .success(let newPhotos):
					self.insertNewPhotos(newPhotos)
					
				case .failure(let error):
					self.delegate?.photoStore(self, loadingFailedWithError: error)
				}
			}
		}
	}
	
	func insertNewPhotos(_ newPhotos: [Photo]) {
		let newPhotosNumber: Int
		let index = numberOfPhotos == 0 ? 0 : numberOfPhotos - 1
		
		if let lastPhoto = photos.last,
			let lastCommonPhotoIndex = newPhotos.firstIndex(of: lastPhoto) {
			
			let newPhotosRange = lastCommonPhotoIndex.advanced(by: 1)..<newPhotos.endIndex
			
			newPhotosNumber = newPhotosRange.count
			photos.append(contentsOf: newPhotos[newPhotosRange])
			
		} else {
			newPhotosNumber = newPhotos.count
			photos.append(contentsOf: newPhotos)
		}
		
		delegate?.photoStore(self, didInsertPhotos: newPhotosNumber, atIndex: index)
	}
}

// MARK: - PinterestCollectionViewLayoutDataSource -
extension PhotoStore: PinterestCollectionViewLayoutDataSource {
	
	func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath,
						whileCellWidthIs cellWidth: CGFloat) -> CGFloat {
		
		let photo = photos[indexPath.item]
		
		let sizeRatio = photo.sizeRatio
		
		return (cellWidth * sizeRatio).rounded()
	}
}
