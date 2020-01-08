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
	
	private var totalPages = 1
	
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
	
	func resetToFirstPage() {
		currentPage = 1
	}
	
	func loadContent() {
		
		setupRequestForNextPage()
		
		guard hasContentToLoad else { return }
		
		networkService.performRequest(request) { [weak self] (result) in
			self?.contentDidLoadHandler?(result)
		}
	}
}
