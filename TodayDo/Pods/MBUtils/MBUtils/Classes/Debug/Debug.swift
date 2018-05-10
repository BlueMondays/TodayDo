//
//  Debug.swift
//  MBUtils
//
//  Created by 박지연 on 2018. 2. 2..
//  Copyright © 2018년 jiyeonpark@mrblue.com. All rights reserved.
//

import Foundation

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
	#if DEBUG
		Swift.print(items[0], separator:separator, terminator: terminator)
	#endif
}
