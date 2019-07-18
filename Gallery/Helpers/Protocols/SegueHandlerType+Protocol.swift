//
//  SegueHandlerType+Protocol.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 2/20/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

protocol SegueHandlerType {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func performSegue(withIdentifier identifier: SegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
    
    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier)
            else { fatalError("Invalid segue identifier \(segue.identifier!).") }
        
        return segueIdentifier
    }
}
