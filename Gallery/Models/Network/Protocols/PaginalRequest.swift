//
//  PaginalRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/23/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

protocol PaginalRequest: UnsplashRequest {
	var page: Int { get set }
	var pageSize: UnsplashPageSize { get }
}
