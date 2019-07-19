//
//  ViewController.swift
//  Roflanplanner
//
//  Created by Admin on 11/03/2019.
//  Copyright © 2019 fefu. All rights reserved.
//

import UIKit
import FSCalendar
import CalendarKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet var calendar: FSCalendar!
    //fileprivate weak var calendar: FSCalendar!
    @IBOutlet var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        
        //let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        //calendar.dataSource = self
        //calendar.delegate = self
        //view.addSubview(calendar)
        //self.calendar = calendar

    }
    

    @IBAction func clickedChangeView(_ sender: Any) {
        if calendar.scope == .month {
            calendar.setScope(.week, animated: true)
        } else {
            self.calendar.setScope(.month, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}


extension ViewController: FSCalendarDataSource, FSCalendarDelegate {

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return Int.random(in: 1..<10)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int.random(in: 1..<10)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {

        let TrashAction = UIContextualAction(style: .normal, title:  "Trash", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("delete action ...")
            success(true)
        })
        TrashAction.backgroundColor = .red
        
        let FlagAction = UIContextualAction(style: .normal, title:  "Flag", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("flag action ...")
            success(true)
        })
        FlagAction.backgroundColor = .orange
        
        let MoreAction = UIContextualAction(style: .normal, title:  "More", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("more action ...")
            success(true)
        })
        MoreAction.backgroundColor = .gray
        
        
        return UISwipeActionsConfiguration(actions: [TrashAction,FlagAction,MoreAction])
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.tableView.reloadData()
        self.calendar.reloadData()
    }

    
    
    
}
