//
//  Reusable.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 11/18/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import UIKit

protocol StringIdentifiable {}

extension StringIdentifiable {
    static var stringIdentifier: String {
        return String(describing: self)
    }
}

extension UIView: StringIdentifiable {}
extension UIViewController: StringIdentifiable {}
