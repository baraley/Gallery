//
//  RequestError.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/20/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

enum RequestError: Error, LocalizedError, Equatable {
	case noInternet, limitExceeded
	case unknown(String)
	
	var errorDescription: String? {
		switch self {
		case .noInternet:			return "The Internet connection appears to be offline."
		case .limitExceeded: 		return "Requests' limit to Unsplash is exceeded"
		case .unknown(let message): return message
		}
	}
}
