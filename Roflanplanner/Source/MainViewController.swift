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

class MainViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var dayTable: UITableView!
    @IBOutlet weak var toggleViewButton: UIBarButtonItem!
    
    var selectedDayInstances : [EventInstance]?
    var selectedInstance : EventInstance!
    var model = CalendarModel()
    var refreshControl = UIRefreshControl()

    @objc func objcRefreshData() {
        self.refreshData()
    }
    
    func refreshData(completion: @escaping () -> Void = {}) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.model.fetchEvents() {
            self.model.fetchPatterns() {
                self.model.fetchInstances() {
                    let date = self.calendar.selectedDate ?? self.calendar.today!
                    self.refreshSelectedDayInstances(date: date)
                    self.calendar.reloadData()
                    self.dayTable.reloadData()
                    print("reloaded")
                    self.refreshControl.endRefreshing()
                    completion()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false

                }
            }
        }
    }
    
    func refreshSelectedDayInstances(date: Date) {
        calendar.setCurrentPage(date, animated: true)
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd"
        let formattedDate = Int(format.string(from: date))!
        self.selectedDayInstances = self.model.instanes[formattedDate]?.sorted(by: { $0.started_at! < $1.started_at! })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(objcRefreshData), for: .valueChanged)
        dayTable.refreshControl = refreshControl
        self.refreshData()
        
    }
    
    @IBAction func clickedChangeView(_ sender: Any) {
        if calendar.scope == .month {
            calendar.setScope(.week, animated: true)
            toggleViewButton.title = "Expand"
        } else {
            self.calendar.setScope(.month, animated: true)
            toggleViewButton.title = "Shrink"

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toEventSegue" {
            
            segue.destination.presentationController?.delegate = self;
            let navController = segue.destination as! UINavigationController
            let eventTableView = navController.topViewController as! EventTableViewController
            eventTableView.event = self.model.events[self.selectedInstance.event_id!]!
            eventTableView.pattern = self.model.patterns[self.selectedInstance.event_id!]!
            
        }
        
        if segue.identifier == "toCreateSegue" {
            
            segue.destination.presentationController?.delegate = self;
            let navController = segue.destination as! UINavigationController
            let eventTableView = navController.topViewController as! EventTableViewController
            eventTableView.selectedDate = self.calendar.selectedDate
            print("create action...")

        }
        
        if segue.identifier == "toWeekSegue" {
            print("week...")
            segue.destination.presentationController?.delegate = self;
            let weekView = segue.destination as! WeekViewController
            weekView.viewModel.initEvents(from: self.model)
            weekView.kek = "BEFORE AFTER"
            
        }
        
    }
    
    var tokenText : UITextField?
    @IBAction func clickedRedeemButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Insert token", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: tokenText)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: self.okHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
        
    }
    
    func tokenText(textField: UITextField!) {
        tokenText = textField
    }
    
    func okHandler(alert: UIAlertAction) {
        if let token = tokenText?.text {
            print(token)
            self.model.getShare(token: token) {
                self.refreshData()
            }
        }
    }
    
}


extension MainViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd"
        let formattedDate = Int(format.string(from: date))!
        if let val = self.model.instanes[formattedDate] {
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

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let val = self.selectedDayInstances {
            return val.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        let instance = self.selectedDayInstances![indexPath.row]
        let event = self.model.events[instance.event_id!]!
        cell.detailTextLabel?.text = event.name
        let pattern = self.model.patterns[instance.event_id!]!
        let from = CalendarModel.convertToDate(pattern.started_at!)
        let to = CalendarModel.convertToDate(pattern.duration! + pattern.started_at!)
        let duration = Date.duration(from: from, to: to)
        cell.textLabel?.text = DateFormatter.localizedString(from: from, dateStyle: .none, timeStyle: .short) + " " + duration
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("show action ...")
        
        self.selectedInstance = self.selectedDayInstances![indexPath.row]
        
        performSegue(withIdentifier: "toEventSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {

        let TrashAction = UIContextualAction(style: .destructive, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("delete action ...")
            print(indexPath.row)
            self.model.deleteEvent(eventInstance: self.selectedDayInstances![indexPath.row]) { 
                self.refreshData()
            }
            self.selectedDayInstances!.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            success(true)
        })
        TrashAction.backgroundColor = .systemRed
        
        let ShareAction = UIContextualAction(style: .normal, title:  "Share", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("share action ...")
            print(indexPath.row)
            self.model.postShare(event: self.model.events[self.selectedDayInstances![indexPath.row].event_id!]!) {
                message in
                let objectsToShare = [message] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                self.present(activityVC, animated: true, completion: nil)
                
            }
            success(true)

        })
        ShareAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [TrashAction, ShareAction])
    }
    
}

extension Date {

    static func duration(from : Date, to : Date) -> String {

        let dayHour: Set<Calendar.Component> = [.day, .hour, .minute]
        let difference = NSCalendar.current.dateComponents(dayHour, from: from, to: to);
        
        
        let minutes = "\(difference.minute ?? 0)" == "0" ? "" : "\(difference.minute ?? 0)m"
        let hours = "\(difference.hour ?? 0)" == "0" ? "" : "\(difference.hour ?? 0)h"
        let days = "\(difference.day ?? 0)d"

        if let day = difference.day, day          > 0 { return "\(days) \(hours)" }
        if let hour = difference.hour, hour       > 0 { return "\(hours) \(minutes)"}
        if let minute = difference.minute, minute > 0 { return minutes }

        return ""
    }

}
