//
//  UnsplashItemsModelController.swift
//  Gallery
//
//  Created by Alexander Baraley on 23.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import Foundation

class UnsplashItemsModelController<Request: PaginalRequest>: NSObject where Request.ResultError == RequestError {
	typealias Model = Request.ContentModel

	private let networkService: NetworkService
	private let request: Request

	init(networkService: NetworkService, request: Request) {
		self.networkService = networkService
		self.request = request

		super.init()
	}

	private lazy var loader: PaginalContentLoader<Request> = createLoader()

	private(set) var items: Array<Model> = [] { didSet { numberOfItems = items.count } }
	private(set) var numberOfItems: Int = 0

	func reloadItems() {
		loader.resetToFirstPage()
		items.removeAll()
		loadMoreItems()
	}

	func loadMoreItems() {
		if loader.loadContent() {
			notifyObservers { $0.itemsLoadingDidStart() }
		}
	}

	func itemAt(_ index: Int) -> Model? {
		guard !items.isEmpty, index >= 0 && index < numberOfItems else { return nil }

		return items[index]
	}

	func updateItemAt(_ index: Int, with item: Model) {
		guard !items.isEmpty, index >= 0 && index < numberOfItems else { return }

		items[index] = item
	}

	// MARK: - Observations

	private struct Observation {
		weak var observer: UnsplashItemsLoadingObserver?
	}

	private var observations = [ObjectIdentifier : Observation]()

	func addObserve(_ observer: UnsplashItemsLoadingObserver) {
		let id = ObjectIdentifier(observer)
		observations[id] = Observation(observer: observer)
	}

	func removeObserver(_ observer: UnsplashItemsLoadingObserver) {
		let id = ObjectIdentifier(observer)
		observations.removeValue(forKey: id)
	}
}

// MARK: - Private
private extension UnsplashItemsModelController {

	func createLoader() -> PaginalContentLoader<Request> {
		let loader = PaginalContentLoader(networkService: networkService, request: request)

		loader.contentDidLoadHandler = { [weak self] (result) in
			DispatchQueue.main.async {
				switch result {
				case .success(let newItems): 	self?.insertLoadedItems(newItems)
				case .failure(let error): 		self?.notifyObservers { $0.itemsLoadingDidFinishWith(error) }
				}
			}
		}
		return loader
	}

	func insertLoadedItems(_ loadedItems: [Model]) {
		let newItemsNumber: Int
		let locationIndex = numberOfItems == 0 ? 0 : numberOfItems

		if let lastItem = items.last, let lastCommonItemIndex = loadedItems.firstIndex(of: lastItem) {

			let newItemsRange = lastCommonItemIndex.advanced(by: 1)..<loadedItems.endIndex

			newItemsNumber = newItemsRange.count
			items.append(contentsOf: loadedItems[newItemsRange])

		} else {
			newItemsNumber = loadedItems.count
			items.append(contentsOf: loadedItems)
		}

		notifyObservers { $0.itemsLoadingDidFinish(numberOfItems: newItemsNumber, locationIndex: locationIndex) }
	}

	func notifyObservers(invoking notification: @escaping (UnsplashItemsLoadingObserver) -> Void) {
		observations.forEach { (key, observation) in
			guard let observer = observation.observer else {
				observations.removeValue(forKey: key)
				return
			}
			notification(observer)
		}
	}
}
