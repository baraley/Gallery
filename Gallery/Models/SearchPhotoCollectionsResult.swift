//
//  SearchPhotoCollectionsResult.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/29/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

struct SearchPhotoCollectionsResult: Decodable {
	
	let total: Int
	let totalPages: Int
	
	let results: [PhotoCollection]
	
	enum CodingKeys: String, CodingKey {
		case total
		case totalPages =  "total_pages"
		case results
	}
	
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		total = try values.decode(Int.self, forKey: .total)
		totalPages = try values.decode(Int.self, forKey: .totalPages)
		results = try values.decode([PhotoCollection].self, forKey: .results)
	}
}
