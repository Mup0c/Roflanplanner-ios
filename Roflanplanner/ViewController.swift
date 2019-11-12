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
    
    @IBOutlet var dayTable: UITableView!
    
    var selectedDayInstances : [EventInstance]?
    var selectedEvent : Event!
    var selectedInstance : EventInstance!
    var willCreateNewEvent = false
    var data = Data()
    var refreshControl = UIRefreshControl()

    @objc private func refreshData(_ sender: Any) {
        self.data.fetchEvents() {
            self.data.fetchInstances {
                let date = self.calendar.selectedDate ?? self.calendar.today!
                self.refreshSelectedDayInstances(date: date)
                self.calendar.reloadData()
                self.dayTable.reloadData()

                print("reloaded")
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func refreshSelectedDayInstances(date: Date) {
        calendar.setCurrentPage(date, animated: true)
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd"
        let formattedDate = Int(format.string(from: date))!
        self.selectedDayInstances = self.data.instanes[formattedDate]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        dayTable.refreshControl = refreshControl
        //calendar.placeholderType = FSCalendarPlaceholderType.fillSixRows
        //calendar.adjustsBoundingRectWhenChangingMonths=true
        self.refreshData(self)
        //calendar.adjustMonthPosition()
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
    
    @IBAction func clickedAddButton(_ sender: Any) {
        print("create action...")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventSegue" {
            let navController = segue.destination as! UINavigationController
            let eventTableView = navController.topViewController as! EventTableViewController
            eventTableView.creatingNewEvent = willCreateNewEvent
            //selectedEvent.details = "THIS is EvEnt details \n \n kek"
            eventTableView.event = selectedEvent
        }
    }
}


extension ViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd"
        let formattedDate = Int(format.string(from: date))!
        if let val = self.data.instanes[formattedDate] {
            return val.count
        }
        return 0
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.setCurrentPage(date, animated: true)
        self.refreshSelectedDayInstances(date: date)
        self.dayTable.reloadData()

    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let val = self.selectedDayInstances {
            return val.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        let instance = self.selectedDayInstances![indexPath.row]
        let event = self.data.events[instance.event_id!]!
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.details
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("show action ...")
        
        let instance = self.selectedDayInstances![indexPath.row]
        self.selectedEvent = self.data.events[instance.event_id!]!
        self.willCreateNewEvent = false
        
        performSegue(withIdentifier: "toEventSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {

        let TrashAction = UIContextualAction(style: .destructive, title:  "Trash", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("delete action ...")
            print(indexPath.row)
            self.selectedDayInstances!.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            success(false)
        })
        TrashAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [TrashAction])
    }
    
}
