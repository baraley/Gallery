//
//  ImageCollectionViewDataSource.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/24/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

protocol ImageCollectionViewDataSource: UICollectionViewDataSource {
	var selectedItemIndex: Int? { get set }
	
	var contentDidStartLoadingAction: (() -> Void)? { get set }
	var newContentDidLoadAction: ((_ numberOfItems: Int, _ index: Int) -> Void)? { get set }
	var contentLoadingWasFailedAction: ((_ error: RequestError) -> Void)? { get set }
	
	func reloadContent(for collectionView: UICollectionView)
	func loadMoreContent(for collectionView: UICollectionView)
	
	func collectionView(_ collectionView: UICollectionView,
						loadContentForCellAt indexPath: IndexPath)
	func collectionView(_ collectionView: UICollectionView,
						cancelLoadingContentForCellAt indexPath: IndexPath)
}
