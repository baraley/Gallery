//
//  PhotosModelController.swift
//  Gallery
//
//  Created by Alexander Baraley on 11.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

enum LoadingEvent {
	case startLoading
	case loadingDidFinish(numberOfPhotos: Int, _ locationIndex: Int)
	case loadingError(error: RequestError)
}

class PhotosModelController: NSObject {

	var eventsHandler: ((LoadingEvent) -> Void)?

	private let networkService: NetworkService
	private let photoListRequest: PhotoListRequest
	private let	accessToken: String?

	init(networkService: NetworkService, photoListRequest: PhotoListRequest) {
		self.networkService = networkService
		self.photoListRequest = photoListRequest
		self.accessToken = photoListRequest.accessToken

		super.init()
	}

	private lazy var photosLoader: PaginalContentLoader<PhotoListRequest> = {
		let loader = PaginalContentLoader(networkService: networkService, request: photoListRequest)
		loader.contentDidLoadHandler = { [weak self] (result) in
			DispatchQueue.main.async {
				switch result {
				case .success(let newPhotos): 	self?.insertNewPhotos(newPhotos)
				case .failure(let error): 		self?.eventsHandler?(.loadingError(error: error))
				}
			}
		}
		return loader
	}()

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
		photosLoader.resetToFirstPage()
		photos.removeAll()
		loadMorePhotos()
	}

	func loadMorePhotos() {
		guard photosLoader.hasContentToLoad else { return }

		eventsHandler?(.startLoading)

		photosLoader.loadContent()
	}

	// MARK: - Like -

	var isLikeTogglingAvailable: Bool {
		return accessToken != nil
	}

	func toggleLikeOf(_ photo: Photo, completionHandler: @escaping (Result<Photo, RequestError>) -> Void) {
		guard let accessToken = accessToken, let index = photos.firstIndex(of: photo) else { return }

		let toggleRequest = TogglePhotoLikeRequest(photo: photo, accessToken: accessToken)

		networkService.performRequest(toggleRequest) { [weak self] (result) in

			DispatchQueue.main.async {
				if let toggledPhoto = try? result.get() {
					self?.photos[index] = toggledPhoto
				}
				completionHandler(result)
			}
		}
	}
}

// MARK: - Private
private extension PhotosModelController {

	func insertNewPhotos(_ newPhotos: [Photo]) {
		let newPhotosNumber: Int
		let locationIndex = numberOfPhotos == 0 ? 0 : numberOfPhotos - 1

		if let lastPhoto = photos.last,
			let lastCommonPhotoIndex = newPhotos.firstIndex(of: lastPhoto) {

			let newPhotosRange = lastCommonPhotoIndex.advanced(by: 1)..<newPhotos.endIndex

			newPhotosNumber = newPhotosRange.count
			photos.append(contentsOf: newPhotos[newPhotosRange])

		} else {
			newPhotosNumber = newPhotos.count
			photos.append(contentsOf: newPhotos)
		}

		eventsHandler?(.loadingDidFinish(numberOfPhotos: newPhotosNumber, locationIndex))
	}
}

// MARK: - PinterestCollectionViewLayoutDataSource -
extension PhotosModelController: PinterestCollectionViewLayoutDataSource {

	func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath,
						whileCellWidthIs cellWidth: CGFloat) -> CGFloat {

		let photo = photos[indexPath.item]

		let sizeRatio = photo.sizeRatio

		return (cellWidth * sizeRatio).rounded()
	}
}

extension PhotosModelController: PhotosTabCollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return numberOfPhotos
	}

	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return collectionView.dequeueCell(indexPath: indexPath) as ImageCollectionViewCell
	}

	func collectionView(_ collectionView: UICollectionView,
						viewForSupplementaryElementOfKind kind: String,
						at indexPath: IndexPath) -> UICollectionReusableView {

		let view = collectionView
			.dequeueSupplementaryView(of: kind, at: indexPath) as CollectionViewLoadingFooter
		return view
	}

	func collectionView(_ collectionView: UICollectionView, loadThumbForCellAt indexPath: IndexPath) {
		guard let photo = photoAt(indexPath.item) else { return }

		let imageRequest = ImageRequest(url: photo.thumbURL)

		networkService.performRequest(imageRequest) { [weak self] (result) in
			guard let self = self else { return }
			DispatchQueue.main.async {
				switch result {
				case .success(let thumb):
					let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
					cell?.imageView.image = thumb

				case .failure(let error):
					self.eventsHandler?(.loadingError(error: error))
				}
			}
		}
	}

	func collectionView(_ collectionView: UICollectionView, cancelLoadingThumbForCellAt indexPath: IndexPath) {
		guard let photo = photoAt(indexPath.item) else { return }

		let imageRequest = ImageRequest(url: photo.thumbURL)

		networkService.cancel(imageRequest)
	}

	
}
