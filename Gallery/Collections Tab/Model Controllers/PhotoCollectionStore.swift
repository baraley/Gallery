//
//  PhotoCollectionStore.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/20/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

final class PhotoCollectionStore: NSObject {
	
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
		guard !photoCollections.isEmpty, index >= 0 && index < numberOfPhotoCollections else {
			return nil
		}
		
		return photoCollections[index]
	}
	
	func indexOf(_ photoCollection: PhotoCollection) -> Int? {
		return photoCollections.firstIndex(of: photoCollection)
	}
	
	var selectedPhotoCollectionIndex: Int?
	
	var contentDidStartLoadingAction: (() -> Void)?
	
	var newContentDidLoadAction: ((_ numberOfItems: Int, _ index: Int) -> Void)?
	
	var contentLoadingWasFailedAction: ((_ error: RequestError) -> Void)?
	
	func reloadPhotoCollections() {
		paginalContentLoader.resetToFirstPage()
		photoCollections.removeAll()
		loadPhotoCollections()
	}
	
	func loadPhotoCollections() {
		guard paginalContentLoader.hasContentToLoad else { return }
		
		contentDidStartLoadingAction?()
		
		paginalContentLoader.loadContent { [weak self] (result) in
			guard let self = self else { return }
			
			DispatchQueue.main.async {
				switch result {
				case .success(let newPhotoCollections):
					self.insertNewPhotos(newPhotoCollections)
					
				case .failure(let error):
					self.contentLoadingWasFailedAction?(error)
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
			
			let newPhotoCollectionsRange = lastCommonPhotoIndex.advanced(by: 1)..<newPhotoCollections.endIndex
			
			newPhotoCollectionsNumber = newPhotoCollectionsRange.count
			photoCollections.append(contentsOf: newPhotoCollections[newPhotoCollectionsRange])
			
		} else {
			newPhotoCollectionsNumber = newPhotoCollections.count
			photoCollections.append(contentsOf: newPhotoCollections)
		}
		newContentDidLoadAction?(newPhotoCollectionsNumber, index)
	}
}

// MARK: - UICollectionViewDataSource
extension PhotoCollectionStore: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView,
								 numberOfItemsInSection section: Int) -> Int {
		return numberOfPhotoCollections
	}
	
	func collectionView(_ collectionView: UICollectionView,
								 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueCell(indexPath: indexPath) as PhotoCollectionCollectionViewCell
		if let photoCollection = photoCollectionAt(indexPath.item) {
			cell.titleLabel.text = photoCollection.title
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView,
								 viewForSupplementaryElementOfKind kind: String,
								 at indexPath: IndexPath) -> UICollectionReusableView {
		
		let view = collectionView
			.dequeueSupplementaryView(of: kind, at: indexPath) as CollectionViewLoadingFooter
		return view
	}
}

extension PhotoCollectionStore: ImagesCollectionViewDataSource {
	var selectedItemIndex: Int? {
		get { return selectedPhotoCollectionIndex }
		set { selectedPhotoCollectionIndex = newValue }
	}
	
	func reloadContent(for collectionView: UICollectionView) {
		reloadPhotoCollections()
		collectionView.reloadData()
	}
	
	func loadMoreContent(for collectionView: UICollectionView) {
		loadPhotoCollections()
	}
	
	func collectionView(_ collectionView: UICollectionView,
						loadContentForCellAt indexPath: IndexPath) {
		
		guard let photoCollection = photoCollectionAt(indexPath.row) else  { return }
		
		networkService.performRequest(ImageRequest(url: photoCollection.thumbURL)) {
			[weak self, weak collectionView] (result) in
			
			guard let self = self, let collectionView = collectionView else { return }
			
			DispatchQueue.main.async {
				switch result {
				case .success(let thumb):
					let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell
					cell?.imageView.image = thumb
					
				case .failure(let error):
					self.contentLoadingWasFailedAction?(error)
				}
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cancelLoadingContentForCellAt indexPath: IndexPath) {
		
		if let photoCollection = photoCollectionAt(indexPath.item) {
			networkService.cancel(ImageRequest(url: photoCollection.thumbURL))
		}
	}
}
