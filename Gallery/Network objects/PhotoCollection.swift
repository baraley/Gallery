//
//  PhotoCollection.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/19/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

struct PhotoCollection: Decodable {
	
	let id: Int
	let title: String
	let descriptionText: String?
	let numberOfPhotos: Int
	let thumbURL: URL
	let imageURL: URL
	
	enum CodingKeys: String, CodingKey {
		case id
		case title
		case descriptionText = "description"
		case numberOfPhotos = "total_photos"
		case coverPhoto = "cover_photo"
	}
	
	enum CoverPhotoKey: String, CodingKey {
		case urls
	}
	
	enum UrlsKey: String, CodingKey {
		case thumb, small, regular, full
	}
	
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(Int.self, forKey: .id)
		title = try values.decode(String.self, forKey: .title)
		descriptionText = try? values.decode(String.self, forKey: .descriptionText)
		numberOfPhotos = try values.decode(Int.self, forKey: .numberOfPhotos)
		
		let coverPhoto = try values.nestedContainer(keyedBy: CoverPhotoKey.self, forKey: .coverPhoto)
		let urls = try coverPhoto.nestedContainer(keyedBy: UrlsKey.self, forKey: .urls)
		thumbURL = try urls.decode(URL.self, forKey: .small)
		imageURL = try urls.decode(URL.self, forKey: .regular)
	}
}

extension PhotoCollection: Equatable {
	static func == (lhs: PhotoCollection, rhs: PhotoCollection) -> Bool {
		return lhs.id == rhs.id && lhs.title == rhs.title
	}
}
