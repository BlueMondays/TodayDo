//
//  UIViewControllerExtension.swift
//  MBUtils
//
//  Created by 박지연 on 2018. 2. 2..
//  Copyright © 2018년 jiyeonpark. All rights reserved.
//

import Foundation

import UIKit

extension UIViewController {
	/*
	1. isNavigatingFromPrevious,isNavigatingFromNext
	viewWillAppear, viewDidAppear 에서만 사용해야 합니다.
	
	2. isNavigatingToPrevious,isNavigatingToNext
	viewWillDisappear, viewDidDisappear 에서만 사용해야 합니다.
	
	- isNavigatingFromPrevious : self가 이전 페이지에서 왔는지에 대한 여부 (이전 페이지에서 push되었을 경우에 사용)
	- isNavigatingFromNext : self가 다음 페이지에서 왔는지에 대한 여부 (다음 페이지에서 pop되어 나왔을 경우에 사용)
	- isNavigatingToPrevious : self가 다음 페이지로 push되는지에 대한 여부 (현재 페이지에서 push되었을 경우에 사용)
	- isNavigatingToNext : self가 이전페이지로 pop되는지에 대한 여부 (현재 페이지에서 pop되는 경우에 사용)
	
	ex ) VC2의 관점에서 설명
	VC1 -(push)-> VC2 : isNavigatingFromPrevious = true
	VC2 -(push)-> VC3 : isNavigatingToNext = true
	
	VC3 -(pop)-> VC2 : isNavigatingFromNext = true
	VC2 -(pop)-> VC1 : isNavigatingToPrevious = true
	*/
	
	public func isNavigatingFromPrevious() -> Bool {
		return self.isMovingToParentViewController
	}
	
	public func isNavigatingFromNext() -> Bool {
		return !self.isMovingToParentViewController
	}
	
	public func isNavigatingToPrevious() -> Bool {
		return self.isMovingFromParentViewController
	}
	
	public func isNavigatingToNext() -> Bool {
		return !self.isMovingFromParentViewController
	}
}

