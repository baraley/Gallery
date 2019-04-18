//
//  UIColor+extension.swift
//  Gallery
//
//  Created by Alexander Baraley on 1/5/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

extension UIColor {
	public convenience init?(hexString: String) {
		let r, g, b: CGFloat
		
		guard hexString.hasPrefix("#"), hexString.count == 7 else { return nil }
		
		let start = hexString.index(hexString.startIndex, offsetBy: 1)
		let hexColor = String(hexString[start...])
		
		let scanner = Scanner(string: hexColor)
		var hexNumber: UInt32 = 0
		
		if scanner.scanHexInt32(&hexNumber) {
			r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
			g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
			b = CGFloat((hexNumber & 0x0000ff)) / 255
			
			self.init(red: r, green: g, blue: b, alpha: 1.0)
			return
		}
		
		return nil
	}
}
