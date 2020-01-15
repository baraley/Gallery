//
//  PhotosModelController.swift
//  Gallery
//
//  Created by Alexander Baraley on 11.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

enum LoadingState {
	case startLoading
	case loadingDidFinish(numberOfPhotos: Int, _ locationIndex: Int)
	case loadingError(error: RequestError)
}

class PhotosModelController: NSObject, PhotosDataSource {

	var loadingEventsHandler: ((LoadingState) -> Void)?

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
				case .failure(let error): 		self?.loadingEventsHandler?(.loadingError(error: error))
				}
			}
		}
		return loader
	}()

	private var photos: [Photo] = [] { didSet { numberOfPhotos = photos.count } }

	private(set) var numberOfPhotos: Int = 0

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
		guard photosLoader.hasContentToLoad && !photosLoader.isLoading else { return }

		loadingEventsHandler?(.startLoading)

		photosLoader.loadContent()
	}

	func photoAt(_ index: Int) -> Photo? {
		guard !photos.isEmpty, index >= 0 && index < numberOfPhotos else { return nil }

		return photos[index]
	}

	func updatePhotoAt(_ index: Int, with photo: Photo) {
		guard !photos.isEmpty, index >= 0 && index < numberOfPhotos else { return }

		photos[index] = photo
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

		loadingEventsHandler?(.loadingDidFinish(numberOfPhotos: newPhotosNumber, locationIndex))
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
