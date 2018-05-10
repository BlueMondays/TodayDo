//
//  StringExtension.swift
//  MBUtils
//
//  Created by 박지연 on 2018. 2. 2..
//  Copyright © 2018년 jiyeonpark@mrblue.com. All rights reserved.
//

import Foundation

extension String {
	public func toDate(formatString: String) -> Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = formatString
		return dateFormatter.date(from: self)
	}
}
