//
//  NetworkRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/9/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

enum HTTPMethod: String {
	case GET, POST, PUT, DELETE
}

protocol NetworkRequest {
	associatedtype Model
	
	var cachePolicy: URLRequest.CachePolicy { get }
	var urlRequest: URLRequest { get }
	
	func decode(_ data: Data, response: URLResponse?) -> Model?
}

extension NetworkRequest {
	
	var cachePolicy: URLRequest.CachePolicy {
		return URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
	}
}


