//
//  NetworkImagePresenter.swift
//  Gallery
//
//  Created by Alexander Baraley on 24.01.2020.
//  Copyright © 2020 Alexander Baraley. All rights reserved.
//

import UIKit

protocol CellWithImage: UICollectionViewCell {

	var image: UIImage? { get set }
}

protocol NetworkImagePresenter: UICollectionViewController {
	associatedtype CellType: CellWithImage

	var networkService: NetworkService { get }

	func imageRequestForImage(at indexPath: IndexPath) -> ImageRequest?
	func imageDidLoadedForCell(at indexPath: IndexPath)
}

extension NetworkImagePresenter {

	func loadImageForCellAt(_ indexPath: IndexPath) {
		guard let request = imageRequestForImage(at: indexPath) else { return }

		networkService.performRequest(request) { [weak self] (result) in
			DispatchQueue.main.async {
				switch result {
				case .success(let image):
					let cell = self?.collectionView.cellForItem(at: indexPath) as? CellType
					cell?.image = image
					self?.imageDidLoadedForCell(at: indexPath)
				case .failure(let error):
					self?.showError(error)
				}
			}
		}
	}

	func cancelLoadingImageForCellAt(_ indexPath: IndexPath) {
		guard let request = imageRequestForImage(at: indexPath) else { return }

		networkService.cancel(request)
	}
}
