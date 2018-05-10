//
//  DateExtension.swift
//  MBUtils
//
//  Created by 박지연 on 2018. 2. 2..
//  Copyright © 2018년 jiyeonpark@mrblue.com. All rights reserved.
//

import Foundation

extension Date {
	public func toString(_ format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
}

