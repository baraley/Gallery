//
//  EditProfileTableViewCell.swift
//  Gallery
//
//  Created by Alexander Baraley on 7/16/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class EditProfileTableViewCell: UITableViewCell {
	
	@IBOutlet private var textView: UITextView!
	
	var editableText: String {
		get { return textView.text ?? "" }
		set { textView.text = newValue }
	}
}
