//
//  UIColorExtension.swift
//  MBUtils
//
//  Created by 박지연 on 2018. 2. 2..
//

import UIKit

extension UIColor {
	public static func rgba(_ r: Int, _ g: Int, _ b: Int, _ a: Int) -> UIColor {
		return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
	}
}

