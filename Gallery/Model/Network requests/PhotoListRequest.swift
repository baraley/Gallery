//
//  PhotoRequest.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/10/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation

struct PhotoListRequest: UnsplashRequest {
    
    var page: Int = 1
    private var pageSize: UnsplashPageSize
    private let order: UnsplashPhotoListOrder
	
	init(pageSize: UnsplashPageSize = .large,
         order: UnsplashPhotoListOrder = .latest,
         accessToken: String? = nil) {
        
        self.pageSize = pageSize
        self.order = order
        self.accessToken = accessToken
		
		endpoint = "/photos"
    }
	
	init(forLikedPhotoOfUser userName: String,
		 pageSize: UnsplashPageSize = .large,
		 order: UnsplashPhotoListOrder = .latest,
		 accessToken: String) {
		
		self.init(pageSize: pageSize, order: order, accessToken: accessToken)
		
		endpoint = "/users/\(userName)/likes"
	}
    
    // MARK: - NetworkRequest
    
    func decode(_ data: Data, response: URLResponse?) -> [Photo]? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let photos = try decoder.decode([Photo].self, from: data)
            return photos
        } catch {
            return nil
        }
    }
    
    // MARK: - UnsplashRequest
    
    private(set) var accessToken: String?
    
    private(set) var method = HTTPMethod.GET
	private(set) var endpoint: String
    
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        items.append(URLQueryItem(name: UnsplashQueryParameterName.page, value: "\(page)"))
        items.append(URLQueryItem(name: UnsplashQueryParameterName.perPage, value: "\(pageSize.rawValue)"))
        items.append(URLQueryItem(name: UnsplashQueryParameterName.orderedBy, value: order.rawValue))
        return items
    }
}
