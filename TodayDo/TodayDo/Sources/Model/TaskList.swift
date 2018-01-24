//
//  TaskList.swift
//  TodayDo
//
//  Created by 박지연 on 2018. 1. 23..
//  Copyright © 2018년 박지연. All rights reserved.
//

import RealmSwift

class TaskList: Object {
	var tasks = List<Task>()
}


