//
//  Device.swift
//  MBUtils
//
//  Created by 박지연 on 2018. 2. 12..
//  Copyright © 2018년 jiyeonpark@mrblue.com. All rights reserved.
//

import Foundation

public struct Device {
	public static func isIPhone() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .phone
	}
	
	public static func isIPad() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .pad
	}
	
	public static func isIphoneX() -> Bool {
		return	UIScreen.main.nativeBounds.height == 2436
	}
	
	public static func topSpace() -> CGFloat {
		guard Device.isIphoneX() else {
			return 0
		}
		
		switch UIApplication.shared.statusBarOrientation {
		case .portrait:
			return 44
		case .portraitUpsideDown:
			return 34
		default:
			return 16
		}
	}
	
	public static func bottomSpace() -> CGFloat {
		guard Device.isIphoneX() else {
			return 0
		}
		
		switch UIApplication.shared.statusBarOrientation {
		case .portrait:
			return 34
		case .portraitUpsideDown:
			return 44
		default:
			return 16
		}
	}
	
	public static func rightSpace() -> CGFloat {
		guard Device.isIphoneX() else {
			return 0
		}
		
		switch UIApplication.shared.statusBarOrientation {
		case .landscapeLeft:
			return 44
		case .landscapeRight:
			return 34
		default:
			return 16
		}
	}
	
	public static func leftSpace() -> CGFloat {
		guard Device.isIphoneX() else {
			return 0
		}
		
		switch UIApplication.shared.statusBarOrientation {
		case .landscapeLeft:
			return 34
		case .landscapeRight:
			return 44
		default:
			return 16
		}
	}
}
