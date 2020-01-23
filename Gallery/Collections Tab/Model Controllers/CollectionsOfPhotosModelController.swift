//
//  CollectionsOfPhotosModelController.swift
//  Gallery
//
//  Created by Alexander Baraley on 22.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import Foundation

class CollectionsOfPhotosModelController: NSObject {

	private let networkService: NetworkService
	private let photoCollectionsListRequest: PhotoCollectionListRequest

	init(networkService: NetworkService, photoCollectionListRequest: PhotoCollectionListRequest) {
		self.networkService = networkService
		self.photoCollectionsListRequest = photoCollectionListRequest

		super.init()
	}

	private lazy var collectionsLoader: PaginalContentLoader<PhotoCollectionListRequest> = instantiateCollectionsLoader()

	private var collections: [PhotoCollection] = [] { didSet { numberOfCollections = collections.count } }
	private(set) var numberOfCollections: Int = 0

	// MARK: - Public

	var selectedPhotoIndex: Int?

	func reloadCollections() {
		collectionsLoader.resetToFirstPage()
		collections.removeAll()
		loadMorePhotos()
	}

	func loadMorePhotos() {
		if collectionsLoader.loadContent() {
			notifyObservers { $0.photosLoadingDidStart() }
		}
	}

	func collectionAt(_ index: Int) -> PhotoCollection? {
		guard !collections.isEmpty, index >= 0 && index < numberOfCollections else { return nil }

		return collections[index]
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
private extension CollectionsOfPhotosModelController {

	func instantiateCollectionsLoader() -> PaginalContentLoader<PhotoCollectionListRequest> {
		let loader = PaginalContentLoader(networkService: networkService, request: photoCollectionsListRequest)

		loader.contentDidLoadHandler = { [weak self] (result) in
			DispatchQueue.main.async {
				switch result {
				case .success(let newCollections):
					self?.insertNewCollections(newCollections)

				case .failure(let error):
					self?.notifyObservers {
						$0.photosLoadingDidFinishWith(error)
					}
				}
			}
		}
		return loader
	}

	func insertNewCollections(_ newCollections: [PhotoCollection]) {
		let newCollectionsNumber: Int
		let locationIndex = numberOfCollections == 0 ? 0 : numberOfCollections - 1

		if let lastPhoto = collections.last,
			let lastCommonPhotoIndex = newCollections.firstIndex(of: lastPhoto) {

			let newCollectionsRange = lastCommonPhotoIndex.advanced(by: 1)..<newCollections.endIndex

			newCollectionsNumber = newCollectionsRange.count
			collections.append(contentsOf: newCollections[newCollectionsRange])

		} else {
			newCollectionsNumber = newCollections.count
			collections.append(contentsOf: newCollections)
		}

		notifyObservers {
			$0.photosLoadingDidFinish(numberOfPhotos: newCollectionsNumber, locationIndex: locationIndex)
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



