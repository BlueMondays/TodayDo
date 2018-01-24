//
//  Task.swift
//  TodayDo
//
//  Created by 박지연 on 2018. 1. 18..
//  Copyright © 2018년 박지연. All rights reserved.
//

import RealmSwift

class Task: Object {
	/* 순서고정 */
	@objc dynamic var isFixedOrder = false
	@objc dynamic var title = ""
	@objc dynamic var date: Date?
	@objc dynamic var isDone = false
	@objc dynamic var indexColor = "clear"
}

