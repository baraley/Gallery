//
//  EditableUserData.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/16/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

struct EditableUserData {
	var userName: String
	var firstName: String
	var lastName: String?
	var location: String?
	var biography: String?
	
	init(user: User) {
		self.userName = user.userName
		self.firstName = user.firstName
		self.lastName = user.lastName ?? ""
		self.location = user.location ?? ""
		self.biography = user.biography ?? ""
	}
}
