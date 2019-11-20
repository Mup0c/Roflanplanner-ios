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

class ViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet var calendar: FSCalendar!
    //fileprivate weak var calendar: FSCalendar!
    @IBOutlet var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var dayTable: UITableView!
    @IBOutlet weak var toggleViewButton: UIBarButtonItem!
    
    var selectedDayInstances : [EventInstance]?
    var selectedInstance : EventInstance!
    var data = Data()
    var refreshControl = UIRefreshControl()

    @objc func refreshData() {
        self.data.fetchEvents() {
            self.data.fetchPatterns {
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
    }
    
    func refreshSelectedDayInstances(date: Date) {
        calendar.setCurrentPage(date, animated: true)
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd"
        let formattedDate = Int(format.string(from: date))!
        self.selectedDayInstances = self.data.instanes[formattedDate]?.sorted(by: { $0.started_at! < $1.started_at! })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        dayTable.refreshControl = refreshControl
        //calendar.placeholderType = FSCalendarPlaceholderType.fillSixRows
        //calendar.adjustsBoundingRectWhenChangingMonths=true
        self.refreshData()
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
            eventTableView.event = self.data.events[self.selectedInstance.event_id!]!
            eventTableView.pattern = self.data.patterns[self.selectedInstance.event_id!]!
            
        }
        
        if segue.identifier == "toCreateSegue" {
            
            segue.destination.presentationController?.delegate = self;
            print("create action...")

        }
        
        if segue.identifier == "toWeekViewSegue" {
            print("week...")

            segue.destination.presentationController?.delegate = self;
            let weekView = segue.destination as! WeekViewController
            weekView.JZEvents = self.data.JZevents
            weekView.str = "kek"
            print(weekView.JZEvents!)
            
        }
        
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        print("Dismissed")
        self.refreshData()
        
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
            self.data.getShare(token: token) {
                self.refreshData()
            }
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
        cell.detailTextLabel?.text = event.name
        let from = Date(timeIntervalSince1970: Double(self.data.patterns[instance.event_id!]!.started_at!) / 1000)
        let to = Date(timeIntervalSince1970: Double(self.data.patterns[instance.event_id!]!.duration! + self.data.patterns[instance.event_id!]!.started_at!) / 1000)
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
            self.data.deleteEvent(eventInstance: self.selectedDayInstances![indexPath.row]) { 
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
            self.data.postShare(event: self.data.events[self.selectedDayInstances![indexPath.row].event_id!]!) {
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
        
        
        let minutes = "\(difference.minute ?? 0)" == "0" ? "" : "\(difference.minute ?? 0)" + "m"
        let hours = "\(difference.hour ?? 0)" == "0" ? "" : "\(difference.hour ?? 0)" + "h"
        let days = "\(difference.day ?? 0)d"

        if let day = difference.day, day          > 0 { return days + " " + hours }
        if let hour = difference.hour, hour       > 0 { return hours + " " + minutes}
        if let minute = difference.minute, minute > 0 { return minutes }

        return ""
    }

}
