//
//  Reusable.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 11/18/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import UIKit

protocol Identifiable {}

extension Identifiable {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UIView: Identifiable {}
extension UIViewController: Identifiable {}
