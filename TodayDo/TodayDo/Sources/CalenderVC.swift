//
//  CalenderVC.swift
//  TodayDo
//
//  Created by 박지연 on 2018. 1. 19..
//  Copyright © 2018년 박지연. All rights reserved.
//

import UIKit
import JBDatePicker

class CalenderVC: UIViewController, JBDatePickerViewDelegate {
	
	@IBOutlet private var datePicker: JBDatePickerView!
//	@IBOutlet weak var monthLabel: UILabel!
//	@IBOutlet weak var dayLabel: UILabel!
	
	lazy var dateFormatter: DateFormatter = {
		
		var formatter = DateFormatter()
		formatter.timeStyle = .none
		formatter.dateStyle = .medium
		return formatter
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		datePicker = JBDatePickerView()
//		view.addSubview(datePicker)
		datePicker.delegate = self
		
		//update dayLabel
//		dayLabel.text = dateFormatter.string(from: Date())
		
		//add constraints
//		datePicker.translatesAutoresizingMaskIntoConstraints = false
//		datePicker.heightAnchor.constraint(equalToConstant: 250).isActive = true
//		datePicker.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
//		if #available(iOS 11.0, *) {
//			datePicker.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
//			datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//		} else {
//			datePicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//			let topguideBottom = self.topLayoutGuide.bottomAnchor
//			datePicker.topAnchor.constraint(equalTo: topguideBottom).isActive = true
//		}
		
		
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	// MARK: - JBDatePickerViewDelegate
	
	func didSelectDay(_ dayView: JBDatePickerDayView) {
		
//		dayLabel.text = dateFormatter.string(from: dayView.date!)
	}
	
	func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {
//		monthLabel.text = monthView.monthDescription
		
	}
	
	//custom first day of week
	var firstWeekDay: JBWeekDay {
		return .sunday
	}
	
	//custom font for weekdaysView
	var fontForWeekDaysViewText: JBFont {
		return JBFont(name: "AvenirNext-MediumItalic", size: .medium)
	}
	
	//custom font for dayLabel
	var fontForDayLabel: JBFont {
		return JBFont(name: "Avenir", size: .medium)
	}
	
	//custom colors
	var colorForWeekDaysViewBackground: UIColor {
		return UIColor.color(r: 209, g: 218, b: 175)
	}
	
	var colorForSelectionCircleForOtherDate: UIColor {
		return UIColor.color(r: 252, g: 190, b: 50)
	}
	
	var colorForSelectionCircleForToday: UIColor {
		return UIColor.color(r: 191, g: 225, b: 225)
	}
	
	//only show the dates of the current month
	var shouldShowMonthOutDates: Bool {
		return false
	}
	
	//custom weekdays view height
	var weekDaysViewHeightRatio: CGFloat {
		return 0.15
	}
	
	//custom selection shape
	var selectionShape: JBSelectionShape {
		return .circle
	}
	
	

}

