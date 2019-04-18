//
//  AuthorizedUserData.swift
//  Gallery
//
//  Created by Alexander Baraley on 6/20/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import Foundation

struct AuthorizedUserData {
    let accessToken: String
    let user: User
}

extension AuthorizedUserData: Equatable {
    static func == (lhs: AuthorizedUserData, rhs: AuthorizedUserData) -> Bool {
        return lhs.accessToken == rhs.accessToken && lhs.user.id == rhs.user.id
    }
}
