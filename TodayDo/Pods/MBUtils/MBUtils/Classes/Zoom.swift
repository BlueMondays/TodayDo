//
//  Zoom.swift
//  MBUtils
//
//  Created by 박지연 on 2018. 2. 12..
//  Copyright © 2018년 jiyeonpark@mrblue.com. All rights reserved.
//

import Foundation

public struct Zoom {
	public static func rect(touch: UITouch, container: UIView?, view: UIView?, scale: CGFloat) -> CGRect {
		/* 줌할때 사용자 터치 영역에 따라 rect */
		let touchView = view == nil ? touch.view : view
		let containerView = container == nil ? touch.view : container
		
		guard let v = touchView, let vTouch = containerView else {
			return CGRect()
		}
		
		let center = touch.location(in: v)
		
		var zoomRect = CGRect()
		
		zoomRect.size = CGSize(width: vTouch.frame.size.width / scale,
							   height: vTouch.frame.size.height / scale)
		
		zoomRect.origin = CGPoint(x: center.x - (zoomRect.size.width / 2),
								  y: center.y - (zoomRect.size.height / 2))
		
		return zoomRect
	}
}
