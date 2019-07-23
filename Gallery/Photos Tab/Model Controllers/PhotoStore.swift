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
	func photoStore(_ store: PhotoStore, didInsertPhotos numberOfPhotos: Int, at index: Int)
	func photoStore(_ store: PhotoStore, loadingFailedWithError error: RequestError)
}

class PhotoStore {
	
	weak var delegate: PhotoStoreDelegate?
	
	private let networkService: NetworkService

	private let paginalContentLoader: PaginalContentLoader<PhotoListRequest>
	private var photoLikesToggle: PhotoLikesToggle?
	
	init(networkService: NetworkService, photoListRequest: PhotoListRequest) {
		self.networkService = networkService
		self.paginalContentLoader = PaginalContentLoader(networkService: networkService,
														 request: photoListRequest)
		
		if let accessToken = photoListRequest.accessToken {
			photoLikesToggle = PhotoLikesToggle(networkService: networkService, accessToken: accessToken)
		}
	}
	
	private var photos: [Photo] = [] { didSet { numberOfPhotos = photos.count } }
	
	private(set) var numberOfPhotos: Int = 0
	
	func photoAt(_ index: Int) -> Photo? {
		guard !photos.isEmpty, index >= 0 && index < numberOfPhotos else { return nil }
		
		return photos[index]
	}
	
	func indexOf(_ photo: Photo) -> Int? {
		return photos.firstIndex(of: photo)
	}
	
	var selectedPhotoIndex: Int?
		
	func reloadPhotos() {
		paginalContentLoader.resetToFirstPage()
		photos.removeAll()
		loadPhotos()
	}
	
	func loadPhotos() {
		guard paginalContentLoader.hasContentToLoad else { return }
		
		delegate?.photoStoreDidStartLoading(self)
		
		paginalContentLoader.loadContent { [weak self] (result) in
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
	
	// MARK: - Like -
	
	var isLikeTogglingAvailable: Bool {
		return photoLikesToggle != nil
	}
	
	func toggleLikeOfPhoto(at index: Int,
						   completionHandler: @escaping (Result<Photo, RequestError>) -> Void ) {
		guard photoLikesToggle != nil else { return }
		
		let photo = photos[index]
		
		photoLikesToggle?.toggleLike(of: photo, completionHandler: { [weak self] (result) in
			DispatchQueue.main.async {
				if let toggledPhoto = try? result.get() {
					self?.photos[index] = toggledPhoto
				}
				completionHandler(result)
			}
		})
	}
}

// MARK: - Private
private extension PhotoStore {
	
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
		
		delegate?.photoStore(self, didInsertPhotos: newPhotosNumber, at: index)
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
