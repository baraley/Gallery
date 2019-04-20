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
	associatedtype ResultModel
	associatedtype ResultError: Error
	
	var cachePolicy: URLRequest.CachePolicy { get }
	var urlRequest: URLRequest { get }
	
	func decode(_ data: Data?, response: URLResponse?, error: Error?) -> Result<ResultModel, ResultError>
}

extension NetworkRequest {
	
	var cachePolicy: URLRequest.CachePolicy {
		return URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
	}
	
	func parseError(_ data: Data?, response: URLResponse?, error: Error?) -> RequestError {
		
		if let error = error as NSError?, error.code == -1009 {
			return .noInternet
		}
		if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 403 {
			return .limitExceeded
		}
		if let dataString = data, let errorString = String(data: dataString, encoding: .utf8) {
			return .unknown(errorString)
		}
		return .unknown(error?.localizedDescription ?? "Unknown error")
	}
}

enum RequestError: Error, LocalizedError {
	case noInternet, limitExceeded
	case unknown(String)
	
	var errorDescription: String? {
		switch self {
		case .noInternet:			return "The Internet connection appears to be offline."
		case .limitExceeded: 		return "Requests rate limit to Unsplash is exceeded"
		case .unknown(let message): return message
		}
	}
}
