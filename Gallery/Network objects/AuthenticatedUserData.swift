//
//  AuthenticatedUserData.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/20/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation

struct AuthenticatedUserData {
    let accessToken: String
    let user: User
}

extension AuthenticatedUserData: Equatable {
    static func == (lhs: AuthenticatedUserData, rhs: AuthenticatedUserData) -> Bool {
        return lhs.accessToken == rhs.accessToken && lhs.user.id == rhs.user.id
    }
}
