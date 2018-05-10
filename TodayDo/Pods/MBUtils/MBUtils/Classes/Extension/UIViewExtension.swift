//
//  UIViewExtension.swift
//  MBUtils
//
//  Created by 박지연 on 2018. 2. 2..
//

import UIKit

extension UIView {
	public func findLayoutConstraint(identifier: String) -> NSLayoutConstraint? {
		return self.constraints.filter { $0.identifier == identifier }.first
	}
}

