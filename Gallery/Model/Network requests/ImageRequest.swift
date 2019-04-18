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
	
    func decode(_ data: Data, response: URLResponse?) -> UIImage? {
        return UIImage(data: data)
    }
}
