//
//  PhotosModelController.swift
//  Gallery
//
//  Created by Alexander Baraley on 11.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

class PhotosModelController: NSObject, PhotosDataSource {

	private let networkService: NetworkService
	private let photoListRequest: PhotoListRequest
	private let	accessToken: String?

	init(networkService: NetworkService, photoListRequest: PhotoListRequest) {
		self.networkService = networkService
		self.photoListRequest = photoListRequest
		self.accessToken = photoListRequest.accessToken

		super.init()
	}

	private lazy var photosLoader: PaginalContentLoader<PhotoListRequest> = instantiatePhotosLoader()

	private var photos: [Photo] = [] { didSet { numberOfPhotos = photos.count } }
	private(set) var numberOfPhotos: Int = 0

	// MARK: - Public

	var selectedPhotoIndex: Int?

	func indexOf(_ photo: Photo) -> Int? {
		return photos.firstIndex(of: photo)
	}

	func reloadPhotos() {
		photosLoader.resetToFirstPage()
		photos.removeAll()
		loadMorePhotos()
	}

	func loadMorePhotos() {
		if photosLoader.loadContent() {
			notifyObservers { $0.photosLoadingDidStart() }
		}
	}

	func photoAt(_ index: Int) -> Photo? {
		guard !photos.isEmpty, index >= 0 && index < numberOfPhotos else { return nil }

		return photos[index]
	}

	func updatePhotoAt(_ index: Int, with photo: Photo) {
		guard !photos.isEmpty, index >= 0 && index < numberOfPhotos else { return }

		photos[index] = photo
	}

    // MARK: - Observations

    private struct Observation {
        weak var observer: PhotosDataSourceObserver?
    }

    private var observations = [ObjectIdentifier : Observation]()

    func addObserve(_ observer: PhotosDataSourceObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

    func removeObserver(_ observer: PhotosDataSourceObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}

// MARK: - Private
private extension PhotosModelController {

	func instantiatePhotosLoader() -> PaginalContentLoader<PhotoListRequest> {
		let loader = PaginalContentLoader(networkService: networkService, request: photoListRequest)

		loader.contentDidLoadHandler = { [weak self] (result) in
			DispatchQueue.main.async {
				switch result {
				case .success(let newPhotos):
					self?.insertNewPhotos(newPhotos)

				case .failure(let error):
					self?.notifyObservers {
						$0.photosLoadingDidFinishWith(error)
					}
				}
			}
		}
		return loader
	}

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

		notifyObservers {
			$0.photosLoadingDidFinish(numberOfPhotos: newPhotosNumber, locationIndex: locationIndex)
		}
	}

	func notifyObservers(invoking notification: @escaping (PhotosDataSourceObserver) -> Void) {
		observations.forEach { (key, observation) in
			guard let observer = observation.observer else {
				observations.removeValue(forKey: key)
				return
			}
			notification(observer)
		}
	}
}

// MARK: - TilesCollectionViewLayoutDataSource -
extension PhotosModelController: TilesCollectionViewLayoutDataSource {

	func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath,
						whileCellWidthIs cellWidth: CGFloat) -> CGFloat {

		let photo = photos[indexPath.item]

		let sizeRatio = photo.sizeRatio

		return (cellWidth * sizeRatio).rounded()
	}
}
