//
//  PhotoCollectionStore.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/20/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

protocol CollectionStoreDelegate: AnyObject {
	func photoCollectionStoreDidStartLoading(_ store: PhotoCollectionStore)
	func photoCollectionStore(_ store: PhotoCollectionStore, didInsertPhotos numberOfPhotos: Int, at index: Int)
	func photoCollectionStore(_ store: PhotoCollectionStore, loadingFailedWithError error: RequestError)
}

class PhotoCollectionStore {
	
	weak var delegate: CollectionStoreDelegate?
	
	private let networkService: NetworkService
	
	private let paginalContentLoader: PaginalContentLoader<PhotoCollectionListRequest>
	
	init(networkService: NetworkService, photoCollectionsListRequest: PhotoCollectionListRequest) {
		self.networkService = networkService
		self.paginalContentLoader = PaginalContentLoader(networkService: networkService,
														 request: photoCollectionsListRequest)
	}
	
	private var photoCollections: [PhotoCollection] = [] { didSet { numberOfPhotoCollections = photoCollections.count } }
	
	private(set) var numberOfPhotoCollections: Int = 0
	
	func photoCollectionAt(_ index: Int) -> PhotoCollection? {
		guard !photoCollections.isEmpty, index >= 0 && index < numberOfPhotoCollections else { return nil }
		
		return photoCollections[index]
	}
	
	func indexOf(_ photoCollection: PhotoCollection) -> Int? {
		return photoCollections.firstIndex(of: photoCollection)
	}
	
	var selectedPhotoCollectionIndex: Int?
	
	func reloadPhotoCollections() {
		paginalContentLoader.resetToFirstPage()
		photoCollections.removeAll()
		loadPhotoCollections()
	}
	
	func loadPhotoCollections() {
		guard paginalContentLoader.hasContentToLoad else { return }
		
		delegate?.photoCollectionStoreDidStartLoading(self)
		
		paginalContentLoader.loadContent { [weak self] (result) in
			guard let self = self else { return }
			
			DispatchQueue.main.async {
				switch result {
				case .success(let newPhotoCollections):
					self.insertNewPhotos(newPhotoCollections)
					
				case .failure(let error):
					self.delegate?.photoCollectionStore(self, loadingFailedWithError: error)
				}
			}
		}
	}
}

// MARK: - Private
private extension PhotoCollectionStore {
	
	func insertNewPhotos(_ newPhotoCollections: [PhotoCollection]) {
		let newPhotoCollectionsNumber: Int
		let index = numberOfPhotoCollections == 0 ? 0 : numberOfPhotoCollections - 1
		
		if let lastPhoto = photoCollections.last,
			let lastCommonPhotoIndex = newPhotoCollections.firstIndex(of: lastPhoto) {
			
			let newPhotosRange = lastCommonPhotoIndex.advanced(by: 1)..<newPhotoCollections.endIndex
			
			newPhotoCollectionsNumber = newPhotosRange.count
			photoCollections.append(contentsOf: newPhotoCollections[newPhotosRange])
			
		} else {
			newPhotoCollectionsNumber = newPhotoCollections.count
			photoCollections.append(contentsOf: newPhotoCollections)
		}
		
		delegate?.photoCollectionStore(self, didInsertPhotos: newPhotoCollectionsNumber, at: index)
	}
}



