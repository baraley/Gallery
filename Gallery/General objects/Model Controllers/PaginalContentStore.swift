//
//  PaginalContentStore.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/27/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

protocol ThumbURLHolder {
	var thumbURL: URL { get }
}

protocol ConfigurableCell: UICollectionViewCell {
	associatedtype Model
	
	var imageView: UIImageView! { get set }
	
	func configure(_ item: Model)
}

class PaginalContentStore<R: PaginalRequest, C: ConfigurableCell>: NSObject, ImagesCollectionViewDataSource
	where R.ContentModel == C.Model, R.ResultError == RequestError, R.ContentModel: ThumbURLHolder {
	
	typealias Model = R.ContentModel
	
	private let networkService: NetworkService
	
	private let paginalContentLoader: PaginalContentLoader<R>
	
	private let accessToken: String?
	
	init(networkService: NetworkService, paginalRequest: R) {
		self.networkService = networkService
		self.paginalContentLoader = PaginalContentLoader(networkService: networkService,
														 request: paginalRequest)
		accessToken = paginalRequest.accessToken
	}
	
	private var items: Array<Model> = [] { didSet { numberOfItems = items.count } }
	
	private(set) var numberOfItems: Int = 0
	
	func itemAt(_ index: Int) -> Model? {
		guard !items.isEmpty, index >= 0 && index < numberOfItems else { return nil }
		
		return items[index]
	}
	
	func indexOf(_ item: Model) -> Int? {
		return items.firstIndex(of: item)
	}
	
	var selectedItemIndex: Int?
	
	var contentDidStartLoadingAction: (() -> Void)?
	
	var newContentDidLoadAction: ((_ numberOfItems: Int, _ index: Int) -> Void)?
	
	var contentLoadingWasFailedAction: ((_ error: RequestError) -> Void)?
	
	func reloadContent() {
		paginalContentLoader.resetToFirstPage()
		items.removeAll()
		loadMoreContent()
	}
	
	func loadMoreContent() {
		guard paginalContentLoader.hasContentToLoad else { return }
		
		contentDidStartLoadingAction?()
		
		paginalContentLoader.loadContent { [weak self] (result) in
			guard let self = self else { return }
			
			DispatchQueue.main.async {
				switch result {
				case .success(let newItems):
					self.insertNewItems(newItems)
					
				case .failure(let error):
					self.contentLoadingWasFailedAction?(error)
				}
			}
		}
	}
	
	private func insertNewItems(_ newItems: [Model]) {
		let newItemsNumber: Int
		let index = numberOfItems == 0 ? 0 : numberOfItems - 1
		
		if let lastItem = items.last,
			let lastCommonItemIndex = newItems.firstIndex(of: lastItem) {
			
			let newItemsRange = lastCommonItemIndex.advanced(by: 1)..<newItems.endIndex
			
			newItemsNumber = newItemsRange.count
			items.append(contentsOf: newItems[newItemsRange])
			
		} else {
			newItemsNumber = newItems.count
			items.append(contentsOf: newItems)
		}
		newContentDidLoadAction?(newItemsNumber, index)
	}
	
	// MARK: - UICollectionViewDataSource
	
	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return numberOfItems
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueCell(indexPath: indexPath) as C
		if let item = itemAt(indexPath.item) {
			cell.configure(item)
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
	
	func collectionView(_ collectionView: UICollectionView, loadContentForCellAt indexPath: IndexPath) {
		guard let item = itemAt(indexPath.item) else { return }
			
		let request = ImageRequest(url: item.thumbURL)
		
		networkService.performRequest(request) { [weak self] (result) in
			guard let self = self else { return }
			DispatchQueue.main.async {
				switch result {
				case .success(let thumb):
					let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
					cell?.imageView.image = thumb
					
				case .failure(let error):
					self.contentLoadingWasFailedAction?(error)
				}
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelLoadingContentForCellAt indexPath: IndexPath) {
		
		guard let item = itemAt(indexPath.item) else { return }
		
		networkService.cancel(ImageRequest(url: item.thumbURL))
	}
}

// MARK: - PinterestCollectionViewLayoutDataSource -
extension PaginalContentStore: PinterestCollectionViewLayoutDataSource where R == PhotoListRequest {
	
	func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath,
						whileCellWidthIs cellWidth: CGFloat) -> CGFloat {
		
		let photo = items[indexPath.item]
		
		let sizeRatio = photo.sizeRatio
		
		return (cellWidth * sizeRatio).rounded()
	}
}

// MARK: - PhotoLikesToggle -
extension PaginalContentStore: PhotoLikesToggle where R == PhotoListRequest {
	
	var isLikeTogglingAvailable: Bool {
		return accessToken != nil
	}
	
	func toggleLikeOfPhoto(
		at index: Int, with completionHandler: @escaping (Result<Photo, RequestError>) -> Void
		) {
		
		guard let photo = itemAt(index), let accessToken = accessToken else { return }
		
		let toggleRequest = TogglePhotoLikeRequest(photo: photo, accessToken: accessToken)
		
		networkService.performRequest(toggleRequest) { [weak self] (result) in
			guard let self = self else { return }
			DispatchQueue.main.async {
				if let toggledPhoto = try? result.get() {
					self.items[index] = toggledPhoto
				}
				completionHandler(result)
			}
		}
	}
}

// MARK: - PhotoPageDataSource -
extension PaginalContentStore: PhotoPageDataSource where R == PhotoListRequest {
	var selectedPhotoIndex: Int? {
		get { return selectedItemIndex }
		set { selectedItemIndex = newValue }
	}
	
	var numberOfPhotos: Int {
		return numberOfItems
	}
	
	func photoAt(_ index: Int) -> Photo? {
		return itemAt(index)
	}
	
	func loadMorePhoto() {
		loadMoreContent()
	}
}

// MARK: - PhotoListRequestDataSource
extension PaginalContentStore: PhotoListRequestDataSource where R == PhotoCollectionListRequest {
	
	func photoListRequestForPhoto(at index: Int) -> PhotoListRequest? {
		guard let photoCollection = itemAt(index) else { return nil }
				
		return PhotoListRequest(photosFromCollection: photoCollection, accessToken: accessToken)
	}
}
