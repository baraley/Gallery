//
//  ImageRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/10/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

struct ImageRequest {
    let url: URL
}

extension ImageRequest: NetworkRequest {
	
	var cachePolicy: URLRequest.CachePolicy {
        return URLRequest.CachePolicy.returnCacheDataElseLoad
    }
	
	var urlRequest: URLRequest {
		return URLRequest(url: url)
	}
	func decode(_ data: Data?, response: URLResponse?, error: Error?) -> Result<UIImage, RequestError> {
		if let data = data, let image = UIImage(data: data) {
			return .success(image)
		}
		
		let error =	parseError(data, response: response, error: error)
		return .failure(error)
	}
}
