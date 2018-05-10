//
//  NotificationCenterExtension.swift
//  MBUtils
//
//  Created by 박지연 on 2018. 2. 2..
//  Copyright © 2018년 jiyeonpark@mrblue.com. All rights reserved.
//

import Foundation

public typealias Noti = NotificationUtils

public struct NotificationUtils {
	public static func addNoti(_ observer: Any, selector aSelector: Selector, name aName: String, object anObject: Any? = nil) {
		NotificationCenter.default.addObserver(observer, selector: aSelector, name: NSNotification.Name(rawValue: aName), object: anObject)
	}
	
	public static func removeNoti(_ observer: Any, name aName: String, object anObject: Any? = nil) {
		NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: aName), object: anObject)
	}
	
	public static func postNoti(name aName: String, object anObject: Any? = nil, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: aName), object: anObject, userInfo: aUserInfo)
	}
}

