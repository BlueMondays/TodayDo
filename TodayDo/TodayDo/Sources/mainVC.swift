//
//  mainVC.swift
//  TodayDo
//
//  Created by 박지연 on 2018. 1. 18..
//  Copyright © 2018년 박지연. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import JBDatePicker
import MBEpubParser

struct My {
	static var cellSnapshot: UIView? = nil
}
struct Path {
	static var initialIndexPath: NSIndexPath? = nil
}

struct Device {
	static func isIphoneX() -> Bool {
		return	UIScreen.main.nativeBounds.height == 2436
	}
}

enum Name {
	case Jiyoen
	case Sanghak
}
	
extension UIColor {
	static func color(r: Int, g: Int, b: Int) -> UIColor {
		return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
	}
	
	static func color(_ str: String) -> UIColor {
		switch str {
		case "red":
			return UIColor.Index.red
		case "orange":
			return UIColor.Index.orange
		case "yellow":
			return UIColor.Index.yellow
		case "green":
			return UIColor.Index.green
		case "blue":
			return UIColor.Index.blue
		case "purple":
			return UIColor.Index.purple
		case "pink":
			return UIColor.Index.pink
		case "clear":
			return UIColor.Index.clear
		default:
			return UIColor.Index.clear
		}
	}
	
	struct Index {
		static var red: UIColor {
			return UIColor.color(r: 166, g: 51, b: 5)
		}
		static var orange: UIColor {
			return UIColor.color(r: 216, g: 125, b: 15)
		}
		static var yellow: UIColor {
			return UIColor.color(r: 244, g: 193, b: 39)
		}
		static var green: UIColor {
			return UIColor.color(r: 73, g: 184, b: 99)
		}
		static var blue: UIColor {
			return UIColor.color(r: 77, g: 155, b: 166)
		}
		static var purple: UIColor {
			return UIColor.color(r: 148, g: 55, b: 255)
		}
		static var pink: UIColor {
			return UIColor.color(r: 215, g: 131, b: 255)
		}
		static var clear: UIColor {
			return UIColor.clear
		}
	}
}

extension Date {
	var yesterday: Date {
		return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
	}
	var tomorrow: Date {
		return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
	}
	var noon: Date {
		return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
	}
	var month: Int {
		return Calendar.current.component(.month, from: self)
	}
	var isLastDayOfMonth: Bool {
		return tomorrow.month != month
	}
}

class mainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, JBDatePickerViewDelegate {
	let abc: () -> (Void) = {}
	let name: String = "https://github.com/Twigz/Game"
	@IBOutlet private var tfTask: UITextView!
	@IBOutlet private var tvTaskList: UITableView!
	@IBOutlet private var btnAdd: UIButton!
	@IBOutlet private var vNavBar: UIView!
	@IBOutlet private var lcNavBarTop: NSLayoutConstraint!
	
	
	@IBOutlet private var vSubAddMenuDate: UIView!
	@IBOutlet private var vSubAddMenu: UIView!
	
	@IBOutlet private var btnSubAddMunuTop: UIButton!
	@IBOutlet private var btnSubAddMunuIndex: UIButton!
	@IBOutlet private var btnSubAddMenuDate: UIButton!
	
	@IBOutlet private var btnSelectDate: UIButton!
	@IBOutlet private var vSubMenuIndex: UIView!
	@IBOutlet private var lcCheckLeading: NSLayoutConstraint!
	@IBOutlet private var vSubAddMenuIndex: UIView!
	@IBOutlet private var vCalender: UIView!
	@IBOutlet private var lcvCalenderTop: NSLayoutConstraint!
	@IBOutlet private var lcTfTaskHeight: NSLayoutConstraint!
	
	@IBOutlet private var datePicker: JBDatePickerView!
	@IBOutlet private var vDim: UIView!
	@IBOutlet private var lcNavTopSpace: NSLayoutConstraint!
	@IBOutlet private var lcvSubAddMenuTopSpace: NSLayoutConstraint!
	
	private var numberOfLines = 1
	private var addNewIndexColor = "clear"
	private var addNewDate: Date? = nil

	private var tasks = List<Task>()
	private let realm = try! Realm()
	private var editCellIndexPath: IndexPath?
	private var dragInitialIndexPath: IndexPath?
	private var dragMoveIndexPath: IndexPath?
	private var dragCellSnapshot: UIView?
	private var vAccessory: UIView!
	
	/* TODO
	- 그룹
	*/
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		tvTaskList.rowHeight = UITableViewAutomaticDimension
		tvTaskList.estimatedRowHeight = 44
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	private func initUI() {
		if let first = realm.objects(TaskList.self).first {
			tasks = first.tasks
		} else if UserDefaults.standard.object(forKey: "isInstallFirst") == nil {
			let tasklist = TaskList()
			
			try? realm.write {
				realm.add(tasklist)
			}
			
			if let tmp = realm.objects(TaskList.self).first, false {
				tasks = tmp.tasks
				
				try? realm.write {
					let addTask1 = Task()
					addTask1.title = "할일을 완료 하려면 왼쪽에서 오른쪽으로 스와이프 하세요."
					addTask1.date = Date()
					
					let addTask2 = Task()
					addTask2.title = "상단 고정, 수정, 삭제메뉴는 오른쪽에서 왼쪽으로 스와이프 하세요."
					addTask2.indexColor = "purple"
					
					tasks.insert(addTask1, at: 0)
					tasks.insert(addTask2, at: 0)
				}
			}
		}
		
		tvTaskList.reloadData()
		
		lcNavTopSpace.constant = Device.isIphoneX() ? 44 : 20
		vNavBar.layoutIfNeeded()
		
		lcvSubAddMenuTopSpace.constant = (Device.isIphoneX() ? 44 : 20) + 60
		vSubAddMenu.layoutIfNeeded()
		
		let longpress = UILongPressGestureRecognizer(target: self, action: #selector(onTaskListDidLongpress))
		longpress.minimumPressDuration = 1.0
		longpress.delegate = self
		tvTaskList.addGestureRecognizer(longpress)
		
		let gestureRight =  UISwipeGestureRecognizer(target: self, action: #selector(onTaskListDidSwipeRight))
		gestureRight.direction = .right
		gestureRight.delegate = self
		tvTaskList.addGestureRecognizer(gestureRight)
		
		
		vSubAddMenu.isHidden = true
		vSubAddMenu.alpha = 0
		
		initSubAddMenu()
		
		[btnAdd, btnSubAddMunuTop, btnSubAddMunuIndex, btnSubAddMenuDate].forEach({
			$0.layer.cornerRadius = 5.0
		})
		
		vCalender.layer.cornerRadius = 15
		datePicker.delegate = self
		
		/* 상단 추가 텍스트뷰 악세사리뷰 */
		let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
		let vAccessory1 = UIView(frame: frame)
		vAccessory1.backgroundColor = UIColor.gray
		vAccessory1.alpha = 0.8
		vAccessory1.translatesAutoresizingMaskIntoConstraints = false
		
		let btnAccessoryAdd = UIButton()
		btnAccessoryAdd.setTitle("추가", for: .normal)
		btnAccessoryAdd.addTarget(self, action: #selector(onBtnAdd), for: .touchUpInside)
		btnAccessoryAdd.setTitleColor(.black, for: .normal)
		vAccessory1.addSubview(btnAccessoryAdd)
		btnAccessoryAdd.translatesAutoresizingMaskIntoConstraints = false
		
		let btnAccessoryCancel = UIButton()
		btnAccessoryCancel.setImage(UIImage(named: "downarrow"), for: .normal)
		btnAccessoryCancel.addTarget(self, action: #selector(onKeyboardEndEditing), for: .touchUpInside)
		
		vAccessory1.addSubview(btnAccessoryCancel)
		btnAccessoryCancel.translatesAutoresizingMaskIntoConstraints = false
		
		vAccessory1.addConstraint(NSLayoutConstraint(item: btnAccessoryAdd,
														 attribute: .top,
														 relatedBy: .equal,
														 toItem: vAccessory1,
														 attribute: .top,
														 multiplier: 1,
														 constant: 0))
		vAccessory1.addConstraint(NSLayoutConstraint(item: btnAccessoryAdd,
													attribute: .bottom,
													relatedBy: .equal,
													toItem: vAccessory1,
													attribute: .bottom,
													multiplier: 1,
													constant: 0))
		vAccessory1.addConstraint(NSLayoutConstraint(item: btnAccessoryAdd,
													attribute: .trailing,
													relatedBy: .equal,
													toItem: vAccessory1,
													attribute: .trailing,
													multiplier: 1,
													constant: 0))
		btnAccessoryAdd.addConstraint(NSLayoutConstraint(item: btnAccessoryAdd,
													attribute: .width,
													relatedBy: .equal,
													toItem: nil,
													attribute: .notAnAttribute,
													multiplier: 1,
													constant: 50))

		vAccessory1.addConstraint(NSLayoutConstraint(item: btnAccessoryCancel,
													attribute: .top,
													relatedBy: .equal,
													toItem: vAccessory1,
													attribute: .top,
													multiplier: 1,
													constant: 0))
		vAccessory1.addConstraint(NSLayoutConstraint(item: btnAccessoryCancel,
													attribute: .bottom,
													relatedBy: .equal,
													toItem: vAccessory1,
													attribute: .bottom,
													multiplier: 1,
													constant: 0))
		vAccessory1.addConstraint(NSLayoutConstraint(item: btnAccessoryCancel,
													attribute: .trailing,
													relatedBy: .equal,
													toItem: btnAccessoryAdd,
													attribute: .leading,
													multiplier: 1,
													constant: 0))
		btnAccessoryCancel.addConstraint(NSLayoutConstraint(item: btnAccessoryCancel,
														 attribute: .width,
														 relatedBy: .equal,
														 toItem: nil,
														 attribute: .notAnAttribute,
														 multiplier: 1,
														 constant: 50))

		tfTask.inputAccessoryView = vAccessory1
		
		
		/* 테이블 셀 텍스트 악세사리 뷰 */
		vAccessory = UIView(frame: frame)
		vAccessory.backgroundColor = UIColor.gray
		vAccessory.alpha = 0.8
		vAccessory.translatesAutoresizingMaskIntoConstraints = false
		
		let btnAccessoryDone = UIButton()
		btnAccessoryDone.setTitle("완료", for: .normal)
		btnAccessoryDone.addTarget(self, action: #selector(onTableCellEndEditing), for: .touchUpInside)
		btnAccessoryDone.setTitleColor(.black, for: .normal)
		vAccessory.addSubview(btnAccessoryDone)
		btnAccessoryDone.translatesAutoresizingMaskIntoConstraints = false
		
		let btnAccessoryCancel1 = UIButton()
		btnAccessoryCancel1.setImage(UIImage(named: "downarrow"), for: .normal)
		btnAccessoryCancel1.addTarget(self, action: #selector(onTableCellEndEditing), for: .touchUpInside)
		
		vAccessory.addSubview(btnAccessoryCancel1)
		btnAccessoryCancel1.translatesAutoresizingMaskIntoConstraints = false
		
		vAccessory.addConstraint(NSLayoutConstraint(item: btnAccessoryDone,
													 attribute: .top,
													 relatedBy: .equal,
													 toItem: vAccessory,
													 attribute: .top,
													 multiplier: 1,
													 constant: 0))
		vAccessory.addConstraint(NSLayoutConstraint(item: btnAccessoryDone,
													 attribute: .bottom,
													 relatedBy: .equal,
													 toItem: vAccessory,
													 attribute: .bottom,
													 multiplier: 1,
													 constant: 0))
		vAccessory.addConstraint(NSLayoutConstraint(item: btnAccessoryDone,
													 attribute: .trailing,
													 relatedBy: .equal,
													 toItem: vAccessory,
													 attribute: .trailing,
													 multiplier: 1,
													 constant: 0))
		btnAccessoryDone.addConstraint(NSLayoutConstraint(item: btnAccessoryDone,
														 attribute: .width,
														 relatedBy: .equal,
														 toItem: nil,
														 attribute: .notAnAttribute,
														 multiplier: 1,
														 constant: 50))
		
		vAccessory.addConstraint(NSLayoutConstraint(item: btnAccessoryCancel1,
													 attribute: .top,
													 relatedBy: .equal,
													 toItem: vAccessory,
													 attribute: .top,
													 multiplier: 1,
													 constant: 0))
		vAccessory.addConstraint(NSLayoutConstraint(item: btnAccessoryCancel1,
													 attribute: .bottom,
													 relatedBy: .equal,
													 toItem: vAccessory,
													 attribute: .bottom,
													 multiplier: 1,
													 constant: 0))
		vAccessory.addConstraint(NSLayoutConstraint(item: btnAccessoryCancel1,
													 attribute: .trailing,
													 relatedBy: .equal,
													 toItem: btnAccessoryDone,
													 attribute: .leading,
													 multiplier: 1,
													 constant: 0))
		btnAccessoryCancel1.addConstraint(NSLayoutConstraint(item: btnAccessoryCancel1,
															attribute: .width,
															relatedBy: .equal,
															toItem: nil,
															attribute: .notAnAttribute,
															multiplier: 1,
															constant: 50))
	}
	
	/* 서브메뉴 이니셜라이징 */
	private func initSubAddMenu() {
		[btnSubAddMunuTop, btnSubAddMunuIndex, btnSubAddMenuDate].forEach({
			$0?.isSelected = $0 == btnSubAddMunuIndex
			$0?.addTarget(self, action: #selector(onBtnSubAddMenusDidTouch), for: .touchUpInside)
		})
		
		[btnSubAddMunuTop, btnSubAddMenuDate].forEach({
			$0.alpha = 0.7
		})
		
		vSubAddMenuIndex.isHidden = false
		btnSelectDate.setTitle("날짜 선택", for: .normal)
		
		(0...8).forEach({
			let btn = vSubMenuIndex.viewWithTag($0) as? UIButton
			btn?.layer.cornerRadius = 5.0
			btn?.addTarget(self, action: #selector(onBtnColorsDidTouch), for: .touchUpInside)
		})
		
		if let btn = vSubMenuIndex.viewWithTag(8) as? UIButton {
			lcCheckLeading.constant = btn.frame.origin.x - 10 + btn.frame.size.width / 2
			vSubAddMenu.layoutIfNeeded()
		}
		
		addNewIndexColor = "clear"
		
		vSubAddMenuDate.isHidden = true
		
		(1...3).forEach({
			let btn = vSubAddMenuDate.viewWithTag($0) as? UIButton
			btn?.layer.cornerRadius = 5.0
			btn?.isSelected = false
			btn?.alpha = btn?.isSelected ?? false ? 1 :0.7
//			btn?.addTarget(self, action: #selector(onBtnSubDateMenusDidTouch), for: .touchUpInside)
		})
		//		addNewDateIndex = -1
	}

	
	/* 서브메뉴 터치시 */
	@objc private func onBtnSubAddMenusDidTouch(sender: UIButton) {
		if sender == btnSubAddMunuTop {
			/* 상단 고정 */
			sender.isSelected = !sender.isSelected
			sender.alpha = sender.isSelected ? 1 : 0.7
		} else if sender == btnSubAddMunuIndex {
			/* 인덱스 */
			btnSubAddMenuDate.isSelected = !btnSubAddMenuDate.isSelected
			btnSubAddMenuDate.alpha = 0.7
			
			sender.isSelected = !sender.isSelected
			sender.alpha = sender.isSelected ? 1 : 0.7
			
			vSubAddMenuIndex.isHidden = false
			vSubAddMenuDate.isHidden = true
		} else if sender == btnSubAddMenuDate {
			/* 날짜 */
			btnSubAddMunuIndex.isSelected = !btnSubAddMunuIndex.isSelected
			btnSubAddMunuIndex.alpha = 0.7
			
			sender.isSelected = !sender.isSelected
			sender.alpha = sender.isSelected ? 1 : 0.7
			
			vSubAddMenuIndex.isHidden = true
			vSubAddMenuDate.isHidden = false
		}
	}
	
	
	/*  인덱스 색상 선택 */
	@objc private func onBtnColorsDidTouch(sender: UIButton) {
		/* 인덱스 색상 선택 */
		lcCheckLeading.constant = sender.frame.origin.x - 10 + sender.frame.size.width / 2
		vSubAddMenu.layoutIfNeeded()
		
		switch sender.tag {
		case 1:
			addNewIndexColor = "red"
		case 2:
			addNewIndexColor = "orange"
		case 3:
			addNewIndexColor = "yellow"
		case 4:
			addNewIndexColor = "green"
		case 5:
			addNewIndexColor = "blue"
		case 6:
			addNewIndexColor = "purple"
		case 7:
			addNewIndexColor = "pink"
		case 8:
			addNewIndexColor = "clear"
		default:
			addNewIndexColor = "clear"
		}
	}
	
	/* 날짜 서브 메뉴 */
	@IBAction private func onSelectToday(_ sender: UIButton) {
		/* 오늘 */
		onCloseCalender(sender)
		
		(1...3).forEach({
			let btn = vSubAddMenuDate.viewWithTag($0) as? UIButton
			btn?.isSelected = btn == sender ? !sender.isSelected : false
			btn?.alpha = btn?.isSelected ?? false ? 1 : 0.7
		})
		
		addNewDate = sender.isSelected ? Date() : nil
	}
	
	@IBAction private func onSelectTomorrow(_ sender: UIButton) {
		/* 내일 */
		
		onCloseCalender(sender)
		
		(1...3).forEach({
			let btn = vSubAddMenuDate.viewWithTag($0) as? UIButton
			btn?.isSelected = btn == sender ? !sender.isSelected : false
			btn?.alpha = btn?.isSelected ?? false ? 1 : 0.7
		})
		
		addNewDate = sender.isSelected ? Date().tomorrow : nil
	}
	
	
	@IBAction private func onSelectDate(_ sender: UIButton) {
		/* 날짜 선택시 하단 캘린더 올라옴 */
		
		view.endEditing(true)
		
		UIView.animate(withDuration: 0.3,
					   animations: {
						self.lcvCalenderTop.constant = -self.vCalender.frame.height
						self.view.layoutIfNeeded()
		})
	}
	
	@IBAction private func onCloseCalender(_ sender: UIButton) {
		/* 날짜 선택 : 하단 캘린더 닫기 */
		UIView.animate(withDuration: 0.3,
					   animations: {
						self.lcvCalenderTop.constant = 0
						self.view.layoutIfNeeded()
		})
		
		tfTask.becomeFirstResponder()
	}
	
	// MARK: - JBDatePickerViewDelegate implementation
	// MARK: - JBDatePickerViewDelegate
	
	func didSelectDay(_ dayView: JBDatePickerDayView) {
		(1...3).forEach({
			let btn = vSubAddMenuDate.viewWithTag($0) as? UIButton
			btn?.isSelected = btn == btnSelectDate ? !btnSelectDate.isSelected : false
			btn?.alpha = btn?.isSelected ?? false ? 1 : 0.7
		})
		
		addNewDate = btnSelectDate.isSelected ? dayView.date : nil
		
		if btnSelectDate.isSelected {
			let df: DateFormatter = DateFormatter()
			df.dateFormat = "MM.dd"
			btnSelectDate.setTitle(df.string(from: addNewDate!), for: .normal)
		} else {
			btnSelectDate.setTitle("날짜 선택", for: .normal)
		}
	}
	
	//custom first day of week
	var firstWeekDay: JBWeekDay {
		return .sunday
	}
	//custom colors
	var colorForWeekDaysViewBackground: UIColor {
		return UIColor.color(r: 0, g: 78, b: 102)
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

	/* 오른쪽으로 스와이프 */
	@objc private func onTaskListDidSwipeRight(gesture: UISwipeGestureRecognizer) {
		let point = gesture.location(in: tvTaskList)
		guard let indexPath = tvTaskList.indexPathForRow(at: point) else {
			return
		}
		
		try? realm.write {
			tasks[indexPath.row].isDone = !tasks[indexPath.row].isDone
		}
		
		tvTaskList.reloadRows(at: [indexPath], with: .none)
	}
	
	/* 롱프레스 하여 이동 */
	@objc private func onTaskListDidLongpress(gesture: UILongPressGestureRecognizer) {
		let locationInView = gesture.location(in: tvTaskList)
		let indexPaths = tvTaskList.indexPathForRow(at: locationInView)
		
		switch gesture.state {
		case .began:
			guard let indexPath = indexPaths,
				let cell = tvTaskList.cellForRow(at: indexPath) else {
				return
			}
			
			dragInitialIndexPath = indexPath
			dragMoveIndexPath = indexPath
			dragCellSnapshot = snapshotOfCell(inputView: cell)
			var center = cell.center
			dragCellSnapshot?.center = center
			dragCellSnapshot?.alpha = 0.0
			tvTaskList.addSubview(dragCellSnapshot!)
			
			UIView.animate(withDuration: 0.25,
						   animations: { () -> Void in
				center.y = locationInView.y
				self.dragCellSnapshot?.center = center
				self.dragCellSnapshot?.alpha = 0.99
				cell.alpha = 0.0
			}, completion: { (finished) -> Void in
				if finished {
					cell.isHidden = true
				}
			})
			
		case .changed:
			
			guard let dragInitIndexpath = dragInitialIndexPath,
				let dragMoveIndexpath = dragMoveIndexPath,
				let indexPath = indexPaths else {
				return
			}
			
			var center = dragCellSnapshot?.center
			center?.y = locationInView.y
			
			if tasks[indexPath.row].isFixedOrder == tasks[dragInitIndexpath.row].isFixedOrder {
				dragCellSnapshot?.center = center!
			} else {
				/* 이동불가 */
			}
			
			guard tasks[indexPath.row].isFixedOrder == tasks[dragInitIndexpath.row].isFixedOrder,
				indexPath != dragMoveIndexpath else {
					return
			}

			try? realm.write {
				tasks.move(from: dragMoveIndexpath.row, to: indexPath.row)
			}
			
			tvTaskList.moveRow(at: dragMoveIndexpath, to: indexPath)
			dragMoveIndexPath = indexPath

		case .ended:
			guard let dragMoveIndexpath = dragMoveIndexPath else {
				return
			}

			let cell = tvTaskList.cellForRow(at: dragMoveIndexpath)
			cell?.isHidden = false
			cell?.alpha = 0.0
			UIView.animate(withDuration: 0.25, animations: { () -> Void in
				self.dragCellSnapshot?.center = (cell?.center)!
				self.dragCellSnapshot?.alpha = 0.0
				cell?.alpha = 1.0
			}, completion: { (finished) -> Void in
				if finished {
					self.dragMoveIndexPath = nil
					self.dragInitialIndexPath = nil
					self.dragCellSnapshot?.removeFromSuperview()
					self.dragCellSnapshot = nil
				}
			})
			
		default:
			break
		}
	}

	private func snapshotOfCell(inputView: UIView) -> UIView {
		/* 해당 셀의 뒤에 나오는 그림자 및 효과 */
		UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
		inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		let cellSnapshot = UIImageView(image: image)
		cellSnapshot.layer.masksToBounds = false
		cellSnapshot.layer.cornerRadius = 0.0
		cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
		cellSnapshot.layer.shadowRadius = 5.0
		cellSnapshot.layer.shadowOpacity = 0.4
		return cellSnapshot
	}

	/* 할일 추가 */
	private func addTask() {
		guard let text = tfTask.text, !text.isEmpty else {
			return
		}
		
		let newTask = Task()
		newTask.isFixedOrder = btnSubAddMunuTop.isSelected
		newTask.title = text
		newTask.date = addNewDate
		newTask.isDone = false
		newTask.indexColor = addNewIndexColor
		
		try! realm.write {
			if newTask.isFixedOrder {
				/* 상단고정 */
				tasks.insert(newTask, at: 0)
				tvTaskList.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
			} else {
				let index = fixOrderlastIndex()
				tasks.insert(newTask, at: index)
				tvTaskList.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
			}
		}

		onAddTaskEndEditing()
	}
	
	private func fixOrderlastIndex() -> Int {
		if let notOrder = self.tasks.filter(NSPredicate(format: "isFixedOrder = false")).first,
			let index = self.tasks.index(of: notOrder) {
			return index
		} else {
			return tasks.count
		}
	}
	
	@IBAction private func onBtnAdd(_ sender: UIButton) {
		/* 추가 버튼 누름 */
		addTask()
	}
	
	@objc private func onKeyboardEndEditing() {
		view.endEditing(true)
		
		UIView.animate(withDuration: 0.2,
					   animations: {
						self.vSubAddMenu.alpha = 0
						self.vDim.alpha = 0
		}, completion: { _ in
			self.vSubAddMenu.isHidden = true
			self.vDim.isHidden = true
			
			
				if self.tfTask.text.isEmpty {
					self.initSubAddMenu()
				}
		})
	}
	
	@objc private func onAddTaskEndEditing() {
		/* 작품 추가가 완료 된 후 */
		view.endEditing(true)
		
		tfTask.text = ""
		addNewDate = nil
		numberOfLines = 1
		lcTfTaskHeight.constant = 40
		lcvSubAddMenuTopSpace.constant = vNavBar.frame.height
		vSubAddMenu.layoutIfNeeded()
		
		UIView.animate(withDuration: 0.2,
					   animations: {
						self.vSubAddMenu.alpha = 0
						self.vDim.alpha = 0
		}, completion: { _ in
			self.vSubAddMenu.isHidden = true
			self.vDim.isHidden = true
			self.initSubAddMenu()
		})
	}
	/**
	textfieled
	*/
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView == tfTask {
			vSubAddMenu.isHidden = false
			vDim.isHidden = false
			
			UIView.animate(withDuration: 0.2,
						   animations: {
							self.vSubAddMenu.alpha = 1
							self.vDim.alpha = 0.3
			})
		} else {
			/* 테이블 셀 텍스트 수정 */
			vSubAddMenu.isHidden = false
			
			UIView.animate(withDuration: 0.2,
						   animations: {
							self.vSubAddMenu.alpha = 1
			})
		}
		
		return
	}
	
	
	func textViewDidChange(_ textView: UITextView) {
		/* 텍스트 변경 높이 */
		let fixedWidth: CGFloat = tfTask.frame.size.width
		let newSize: CGSize = tfTask.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
		
		let textRectHeight = newSize.height - tfTask.contentInset.top - tfTask.contentInset.bottom - tfTask.textContainerInset.top - tfTask.textContainerInset.bottom
		let lines = Int(textRectHeight / (tfTask.font?.lineHeight)!)
		
		
		if numberOfLines != lines {
			numberOfLines = lines
			
			if numberOfLines < 3 {
				let tfHeight = newSize.height > 40 ? newSize.height : 40
				tfTask.isScrollEnabled = false
				tfTask.frame.size = CGSize(width: fixedWidth, height: tfHeight)
				lcTfTaskHeight.constant = tfHeight
				tfTask.layoutIfNeeded()
				
				lcvSubAddMenuTopSpace.constant = tfHeight + lcNavTopSpace.constant + 20
				vSubAddMenu.layoutIfNeeded()
			} else {
				tfTask.isScrollEnabled = true
				tfTask.setContentOffset(CGPoint(x: 0, y: tfTask.contentSize.height - lcTfTaskHeight.constant), animated: false)
			}
		}
	}
	
	@objc private func onTableCellEndEditing() {
		guard let indexpath = editCellIndexPath,
			let editcell = tvTaskList.cellForRow(at: indexpath) else {
				return
		}

		let editfield = editcell.viewWithTag(1) as? UITextView
		
		UIView.animate(withDuration: 0.3,
					   animations: {
						self.lcvSubAddMenuTopSpace.constant = (Device.isIphoneX() ? 44 : 20) + 60
						self.view.layoutIfNeeded()
						
						self.vSubAddMenu.alpha = 0
		},
					   completion: { _ in
						self.vSubAddMenu.isHidden = true
		})
		
		for cell in tvTaskList.visibleCells {
			UIView.animate(withDuration: 0.3,
						   animations: {
							cell.transform = CGAffineTransform.identity
							if cell != editcell {
								cell.alpha = 1.0
							}
			}, completion: { (Finished: Bool) -> Void in
			})
		}
		
		var to = 0
		
		try! realm.write {
			if tasks[indexpath.row].isFixedOrder != btnSubAddMunuTop.isSelected {
				to = btnSubAddMunuTop.isSelected ? 0 : fixOrderlastIndex()
			}
			
			tasks.move(from: indexpath.row, to: to)
			tvTaskList.moveRow(at: indexpath, to: IndexPath(row: to, section: 0))
			
			self.tasks[to].title = editfield?.text ?? ""
			self.tasks[to].isFixedOrder = self.btnSubAddMunuTop.isSelected
			self.tasks[to].date = self.addNewDate
			self.tasks[to].indexColor = self.addNewIndexColor
		}
		
		
		initSubAddMenu()
		tvTaskList.reloadRows(at: [IndexPath(row: to, section: 0)], with: .none)
		editCellIndexPath = nil
		
		if let tf = editfield {
			tf.isEditable = false
			view.endEditing(true)
		}
	}
	
	
	/**
	 tableviews
	*/
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks.count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
		view.backgroundColor = UIColor.color(r: 250, g: 211, b: 208)
		let df: DateFormatter = DateFormatter()
		df.dateFormat = "오늘은 yyyy년 MM월 dd일"
		Date().stripped()
		let lb = UILabel()
		lb.font = UIFont.systemFont(ofSize: 30, weight: .light)
		lb.text = df.string(from: Date())
		view.addSubview(lb)
		lb.translatesAutoresizingMaskIntoConstraints = false
		
		view.addConstraint(NSLayoutConstraint(item: lb,
											  attribute: .top,
											  relatedBy: .equal,
											  toItem: view,
											  attribute: .top,
											  multiplier: 1,
											  constant: 0))
		view.addConstraint(NSLayoutConstraint(item: lb,
											  attribute: .bottom,
											  relatedBy: .equal,
											  toItem: view,
											  attribute: .bottom,
											  multiplier: 1,
											  constant: 0))
		view.addConstraint(NSLayoutConstraint(item: lb,
											  attribute: .trailing,
											  relatedBy: .equal,
											  toItem: view,
											  attribute: .trailing,
											  multiplier: 1,
											  constant: 0))
		view.addConstraint(NSLayoutConstraint(item: lb,
											  attribute: .leading,
											  relatedBy: .equal,
											  toItem: view,
											  attribute: .leading,
											  multiplier: 1,
											  constant: 10))
		
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
		
		if cell == nil {
			cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
			
			let vLeft = UIView()
			cell?.contentView.addSubview(vLeft)
			vLeft.translatesAutoresizingMaskIntoConstraints = false
			
			cell?.contentView.addConstraint(NSLayoutConstraint(item: vLeft,
															   attribute: .top,
															   relatedBy: .equal,
															   toItem: cell?.contentView,
															   attribute: .top,
															   multiplier: 1,
															   constant: 0))
			
			cell?.contentView.addConstraint(NSLayoutConstraint(item: vLeft,
															   attribute: .bottom,
															   relatedBy: .equal,
															   toItem: cell?.contentView,
															   attribute: .bottom,
															   multiplier: 1,
															   constant: 0))
			
			cell?.contentView.addConstraint(NSLayoutConstraint(item: vLeft,
															   attribute: .leading,
															   relatedBy: .equal,
															   toItem: cell?.contentView,
															   attribute: .leading,
															   multiplier: 1,
															   constant: 0))
			vLeft.addConstraint(NSLayoutConstraint(item: vLeft,
												   attribute: .width,
												   relatedBy: .equal,
												   toItem: nil,
												   attribute: .notAnAttribute,
												   multiplier: 1,
												   constant: 70))
			
			let vIndex = UIView()
			vIndex.tag = 2
			vLeft.addSubview(vIndex)
			vIndex.translatesAutoresizingMaskIntoConstraints = false
			
			vLeft.addConstraint(NSLayoutConstraint(item: vIndex,
												   attribute: .top,
												   relatedBy: .equal,
												   toItem: vLeft,
												   attribute: .top,
												   multiplier: 1,
												   constant: 0))
			
			vLeft.addConstraint(NSLayoutConstraint(item: vIndex,
													attribute: .bottom,
													relatedBy: .equal,
													toItem: vLeft,
													attribute: .bottom,
													multiplier: 1,
													constant: 0))
			
			vLeft.addConstraint(NSLayoutConstraint(item: vIndex,
													attribute: .leading,
													relatedBy: .equal,
													toItem: vLeft,
													attribute: .leading,
													multiplier: 1,
													constant: 0))
			
			vIndex.addConstraint(NSLayoutConstraint(item: vIndex,
													attribute: .width,
													relatedBy: .equal,
													toItem: nil,
													attribute: .notAnAttribute,
													multiplier: 1,
													constant: 10))
			
			let lbDate = UILabel()
			lbDate.tag = 3
			vLeft.addSubview(lbDate)
			lbDate.translatesAutoresizingMaskIntoConstraints = false
			
			vLeft.addConstraint(NSLayoutConstraint(item: lbDate,
												   attribute: .top,
												   relatedBy: .equal,
												   toItem: vLeft,
												   attribute: .top,
												   multiplier: 1,
												   constant: 0))
			
			vLeft.addConstraint(NSLayoutConstraint(item: lbDate,
												   attribute: .bottom,
												   relatedBy: .equal,
												   toItem: vLeft,
												   attribute: .bottom,
												   multiplier: 1,
												   constant: 0))
			
			vLeft.addConstraint(NSLayoutConstraint(item: lbDate,
												   attribute: .leading,
												   relatedBy: .equal,
												   toItem: vIndex,
												   attribute: .trailing,
												   multiplier: 1,
												   constant: 10))
			
			vLeft.addConstraint(NSLayoutConstraint(item: lbDate,
													attribute: .trailing,
													relatedBy: .equal,
													toItem: vLeft,
													attribute: .trailing,
													multiplier: 1,
													constant: -10))
			
			let vSeparator = UIView()
			vLeft.addSubview(vSeparator)
			vSeparator.backgroundColor = UIColor.lightGray
			vSeparator.translatesAutoresizingMaskIntoConstraints = false
			
			vLeft.addConstraint(NSLayoutConstraint(item: vSeparator,
												   attribute: .top,
												   relatedBy: .equal,
												   toItem: vLeft,
												   attribute: .top,
												   multiplier: 1,
												   constant: 0))
			
			vLeft.addConstraint(NSLayoutConstraint(item: vSeparator,
												   attribute: .bottom,
												   relatedBy: .equal,
												   toItem: vLeft,
												   attribute: .bottom,
												   multiplier: 1,
												   constant: 0))
			
			vLeft.addConstraint(NSLayoutConstraint(item: vSeparator,
												   attribute: .trailing,
												   relatedBy: .equal,
												   toItem: vLeft,
												   attribute: .trailing,
												   multiplier: 1,
												   constant: 0))
			
			vSeparator.addConstraint(NSLayoutConstraint(item: vSeparator,
													attribute: .width,
													relatedBy: .equal,
													toItem: nil,
													attribute: .notAnAttribute,
													multiplier: 1,
													constant: 1 / UIScreen.main.scale ))
			
			
			
			
			let textfield = UITextView()
			textfield.font = UIFont.systemFont(ofSize: 14)
			textfield.tag = 1
			textfield.delegate = self
			textfield.isEditable = false
			textfield.isScrollEnabled = false
			textfield.isUserInteractionEnabled = false
			cell?.contentView.addSubview(textfield)
			textfield.translatesAutoresizingMaskIntoConstraints = false

			cell?.contentView.addConstraint(NSLayoutConstraint(item: textfield,
													   attribute: .top,
													   relatedBy: .equal,
													   toItem: cell?.contentView,
													   attribute: .top,
													   multiplier: 1,
													   constant: 10))
			
			let height = NSLayoutConstraint(item: textfield,
											attribute: .height,
											relatedBy: .equal,
											toItem: nil,
											attribute: .notAnAttribute,
											multiplier: 1,
											constant: 40)
			height.identifier = "height"
			height.priority = UILayoutPriority(rawValue: 999)
			textfield.addConstraint(height)
			
			cell?.contentView.addConstraint(NSLayoutConstraint(item: textfield,
													   attribute: .bottom,
													   relatedBy: .equal,
													   toItem: cell?.contentView,
													   attribute: .bottom,
													   multiplier: 1,
													   constant: -10))
			
			cell?.contentView.addConstraint(NSLayoutConstraint(item: textfield,
													   attribute: .trailing,
													   relatedBy: .equal,
													   toItem: cell?.contentView,
													   attribute: .trailing,
													   multiplier: 1,
													   constant: -10))
			

			textfield.inputAccessoryView = vAccessory

			let iv = UIImageView()
			iv.tag = 4
			iv.image = UIImage(named: "pin")
			iv.contentMode = .scaleAspectFit
			cell?.contentView.addSubview(iv)
			iv.translatesAutoresizingMaskIntoConstraints = false
			
			cell?.contentView.addConstraint(NSLayoutConstraint(item: iv,
															   attribute: .top,
															   relatedBy: .equal,
															   toItem: cell?.contentView,
															   attribute: .top,
															   multiplier: 1,
															   constant: 0))
			
			cell?.contentView.addConstraint(NSLayoutConstraint(item: iv,
															   attribute: .bottom,
															   relatedBy: .equal,
															   toItem: cell?.contentView,
															   attribute: .bottom,
															   multiplier: 1,
															   constant: 0))

			cell?.contentView.addConstraint(NSLayoutConstraint(item: iv,
															   attribute: .leading,
															   relatedBy: .equal,
															   toItem: vLeft,
															   attribute: .trailing,
															   multiplier: 1,
															   constant: 7))

			cell?.contentView.addConstraint(NSLayoutConstraint(item: iv,
															   attribute: .trailing,
															   relatedBy: .equal,
															   toItem: textfield,
															   attribute: .leading,
															   multiplier: 1,
															   constant: -3))

			iv.addConstraint(NSLayoutConstraint(item: iv,
												attribute: .width,
												relatedBy: .equal,
												toItem: nil,
												attribute: .notAnAttribute,
												multiplier: 1,
												constant: 12))
		}
		
		let task = tasks[indexPath.row]
		
		let attributeString =  NSMutableAttributedString(string: task.title)
		if task.isDone {
			attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle,
										 value: 2,
										 range: NSMakeRange(0, attributeString.length))
		}
		
		let label = cell?.viewWithTag(1) as? UITextView
		label?.attributedText = attributeString
		
		if let lb = label, let height = lb.constraints.filter({ $0.identifier == "height" }).first {
			let fixedWidth = tvTaskList.frame.width - 85
			let newSize = lb.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
			
			let tfHeight = newSize.height > 40 ? newSize.height : 40
			lb.isScrollEnabled = true
			lb.frame.size = CGSize(width: fixedWidth, height: tfHeight)
			height.constant = tfHeight
			lb.layoutIfNeeded()
		}
		
		let vIndex = cell?.viewWithTag(2)
		vIndex?.backgroundColor = UIColor.color(task.indexColor)
		
		let df: DateFormatter = DateFormatter()
		df.dateFormat = "MM.dd"
		
		let lbDate = cell?.viewWithTag(3) as? UILabel
		lbDate?.font = UIFont.systemFont(ofSize: 14)
		if let date = task.date {
			lbDate?.text = df.string(from: date)
		} else {
			lbDate?.text = ""
		}
		
		let iv = cell?.viewWithTag(4) as? UIImageView
		iv?.isHidden = !task.isFixedOrder
		
		
		return cell!
	}
	
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .none
	}
	
	func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		try? realm.write {
			tasks.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
		}
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		guard editCellIndexPath == nil else {
			return nil
		}
		
		let isFixedOrder = tasks[indexPath.row].isFixedOrder
		let pin = UITableViewRowAction(style: .normal,
									   title: isFixedOrder ? "해제": "고정",
										handler: { (action, indexpath) in
											
											if isFixedOrder {
												let from = indexpath.row
												var to = self.tasks.count - 1
												
												/* 고정해제 */
												if let notOrder = self.tasks.filter(NSPredicate(format: "isFixedOrder = false")).first,
													let index = self.tasks.index(of: notOrder) {
													to = index-1
												}
												
												try? self.realm.write {
													self.tasks.move(from: from, to: to)
													self.tasks[to].isFixedOrder = false
												}
												
												self.tvTaskList.moveRow(at: IndexPath(row: from, section: 0), to: IndexPath(row: to, section: 0))
												self.tvTaskList.reloadRows(at: [IndexPath(row: to, section: 0)], with: .automatic)
											} else {
												try? self.realm.write {
													self.tasks.move(from: indexpath.row, to: 0)
													self.tasks[0].isFixedOrder = true
												}
												self.tvTaskList.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
												self.tvTaskList.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
											}
		})
		pin.backgroundColor = UIColor.color(r: 255, g: 195, b: 207)
		
		let edit = UITableViewRowAction(style: .normal,
										  title: "수정",
										  handler: { (action, indexpath) in
											
											guard let editingCell = tableView.cellForRow(at: indexpath),
												let tf = editingCell.viewWithTag(1) as? UITextView else {
												return
											}
											
											UIView.animate(withDuration: 0.3,
														   animations: {
															self.lcvSubAddMenuTopSpace.constant = Device.isIphoneX() ? 44 : 20
															self.view.layoutIfNeeded()
											})
											
											
											self.editCellIndexPath = indexpath
											let editingOffset = tableView.contentOffset.y - editingCell.frame.origin.y + 98 - 60
											
											tf.isEditable = true
											tf.becomeFirstResponder()
											
											for cell in tableView.visibleCells {
												cell.transform = CGAffineTransform(translationX: 0, y: editingOffset)
												if cell != editingCell {
													cell.alpha = 0.3
												}
											}
		})
		edit.backgroundColor = UIColor.color(r: 255, g: 203, b: 150)
		
		let delete = UITableViewRowAction(style: .default,
										  title: "삭제",
										  handler: { (action, indexpath) in
											
											try? self.realm.write {
												self.tasks.remove(at: indexpath.row)
											}
											
											tableView.deleteRows(at: [indexpath], with: .automatic)
		})
		delete.backgroundColor = UIColor.color(r: 126, g: 168, b: 186)
		
		return [delete, edit, pin]
	}
}




