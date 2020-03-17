//
//  PaginalContentLoader.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/19/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

class PaginalContentLoader<Request: PaginalRequest> {

	typealias Handler = (Result<Request.ResultModel, Request.ResultError>) -> Void

	// MARK: - Initialization
	
	private let networkService: NetworkService
	private var request: Request

	init(networkService: NetworkService, request: Request) {

		self.networkService = networkService
		self.request = request
		
		let pagesNumberRequest = PagesNumberRequest(from: request)
		networkService.performRequest(pagesNumberRequest) { [weak self] (result) in
			if let totalPages = try? result.get() {
				DispatchQueue.main.async { self?.totalPages = totalPages }
			}
		}
	}

	// MARK: - Private
	#warning("when items loading finished faster than number of pages request loading of next page happens only after the actual number of pages is returned")
	private var totalPages = 2
	
	private var currentPage: Int  {
		get { return request.page }
		set { request.page = newValue }
	}
	
	private func setupRequestForNextPage() {
		if totalPages > request.page {
			request.page += 1
		}
	}

	// MARK: - Public

	var contentDidLoadHandler: Handler?
	
	var hasContentToLoad: Bool {
		return currentPage <= totalPages
	}

	var isLoading: Bool = false
	
	func resetToFirstPage() {
		currentPage = 1
	}
	
	func loadContent() -> Bool {
		guard hasContentToLoad, !isLoading else { return false }

		isLoading = true
		
		networkService.performRequest(request) { [weak self] (result) in
			self?.isLoading = false
			self?.contentDidLoadHandler?(result)
			self?.setupRequestForNextPage()
		}

		return true
	}
}
