//
//	NibLoadableView.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/8/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

protocol NibLoadableView: StringIdentifiable {}

extension UIView: NibLoadableView {
	
	static func instantiate<T: UIView>() -> T {
		let bundle = Bundle(for: self)
		let nib = UINib.init(nibName: stringIdentifier, bundle: bundle)
		guard let view = nib.instantiate(withOwner: nil, options: nil).first as? T else {
			fatalError("Could not instantiate \(stringIdentifier)")
		}
		return view
	}
}
