//
//  EventTableViewController.swift
//  Roflanplanner
//
//  Created by Admin on 01.11.2019.
//  Copyright © 2019 fefu. All rights reserved.
//

import UIKit

class EventTableViewController: UITableViewController, UITextViewDelegate {

    var event : Event!
    var pattern: Pattern!
    
    var selectedDate : Date?
    var editingState : Bool!
    
    var datePickerStart : UIDatePicker!
    var datePickerEnd : UIDatePicker!
    var datePickerDuration : UIDatePicker!
    
    @IBOutlet var weekdayButtons: [UIButton]!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var eventNameCell: UITableViewCell!
    
    @IBOutlet weak var eventDetailsTextView: UITextView!
    @IBOutlet weak var eventNameTextView: UITextView!
    
    @IBOutlet weak var dateTextStart: UITextView!
    @IBOutlet weak var dateTextEnd: UITextView!
    @IBOutlet weak var dateTextDuration: UITextView!
    
    @IBAction func clickedEditButton(_ sender: Any) {
        
        editingState = !editingState

        if !editingState {
            saveData()
        }
        refreshAppearance()

        print("Edit pressed")
        
    }
    
    @IBAction func clickedWeekdayButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        print("PRESSED button")
        print(sender.tag)
    }
    
    func getWeekday(from date: Date) -> Int {
        return (Calendar.current.component(.weekday, from: date) + 5) % 7
    }
    
    func saveData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        editButton.isEnabled = false

        let willCreateNewEvent = event == nil
        event = event ?? Event()
        pattern = pattern ?? Pattern()

        event.details = eventDetailsTextView.text
        event.name = eventNameTextView.text
        pattern.started_at = Int64(datePickerStart.date.timeIntervalSince1970 * 1000)
        pattern.ended_at = max(Int64(datePickerDuration.date.timeIntervalSince1970 * 1000), pattern.started_at!)
        pattern.duration = Int64((datePickerEnd.date.timeIntervalSince1970 - datePickerStart.date.timeIntervalSince1970) * 1000)
        var weekdays : Array<Int> = []


        for button in weekdayButtons {
            if button.isSelected {
                weekdays.append(button.tag)
            }
        }

        let weekday = getWeekday(from: datePickerStart.date)
        print("weekday_index: ", weekday)
        if !weekdays.isEmpty && weekdays.firstIndex(of: weekday) == nil{
            weekdays.append(weekday)
        }
        pattern.setRRuleWeekly(from: weekdays)
        print(weekdays)
        
        let completion = {
            let navCtrlPresCtrl = self.navigationController!.presentationController!
            if let viewCtrl = navCtrlPresCtrl.delegate as? ViewController {
                print("reloading via EventTableViewController")
                viewCtrl.calendar.select(self.datePickerStart.date)
                viewCtrl.refreshData() {
                    self.dismiss(animated: true, completion: {})
                }
            }
        }
        
        if willCreateNewEvent {
            Data.postEvent(event: event, pattern: pattern, completion: completion)
        } else {
            Data.patchEvent(event: event, pattern: pattern, completion: completion)
        }
        
    }
    
    func refreshAppearance() {
        
        
        if !editingState {
            editButton.title = "Edit"
            navigationBar.title = event?.name
            eventNameTextView.text = event?.name
            eventDetailsTextView.text = event?.details
            
            
            datePickerStart.date = Data.convertToDate(pattern.started_at!)
            datePickerEnd.date = Data.convertToDate(pattern.started_at! + pattern.duration!)
            datePickerDuration.date = Data.convertToDate(pattern.ended_at!)
            
            if eventDetailsTextView.text.isEmpty {
                eventDetailsTextView.text = "No details"
            }

            eventNameCell.isHidden = true
            eventNameTextView.isEditable = false
            eventDetailsTextView.isEditable = false
            dateTextEnd.isSelectable = false
            dateTextDuration.isSelectable = false
            dateTextStart.isSelectable = false
            for button in weekdayButtons {
                if !button.isEnabled {
                    button.isSelected = true
                }
                button.isEnabled = false
            }
            

        } else {
            editButton.title = "Done"
            
            
            
            eventNameCell.isHidden = false
            eventNameTextView.isEditable = true
            eventDetailsTextView.isEditable = true
            dateTextEnd.isSelectable = true
            dateTextDuration.isSelectable = true
            dateTextStart.isSelectable = true
            for button in weekdayButtons {
                button.isEnabled = true
            }
            
            eventDetailsTextView.text = event?.details

        }
        dateTextStart.text = DateFormatter.localizedString(from: datePickerStart.date, dateStyle: .full, timeStyle: .short)
        dateTextEnd.text = DateFormatter.localizedString(from: datePickerEnd.date, dateStyle: .full, timeStyle: .short)
        dateTextDuration.text = DateFormatter.localizedString(from: datePickerDuration.date, dateStyle: .full, timeStyle: .none)
        
        let weekday = getWeekday(from: datePickerStart.date)
        weekdayButtons[weekday].isEnabled = false
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        editingState = event == nil
        initDatePickers()
        eventNameTextView.delegate = self
        weekdayButtons = weekdayButtons.sorted(by: { $0.tag < $1.tag })

        refreshAppearance()
        
        if let weekdays = pattern?.getWeekdays() {
            print("weekdays", weekdays)
            for day in weekdays{
                weekdayButtons[day].isSelected = true
            }
        }
        
        
        print("Event table view loaded")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Unnamed" && textView.tag == 2 {
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty && textView.tag == 2 {
            textView.text = "Unnamеd"
        }
    }
    
    func initDatePickers() {
        datePickerEnd = UIDatePicker()
        datePickerStart = UIDatePicker()
        datePickerDuration = UIDatePicker()
        datePickerEnd.datePickerMode = .dateAndTime
        datePickerStart.datePickerMode = .dateAndTime
        datePickerDuration.datePickerMode = .date
        dateTextStart.inputView = datePickerStart
        dateTextEnd.inputView = datePickerEnd
        dateTextDuration.inputView = datePickerDuration
        
        datePickerEnd.addTarget(self, action: #selector(dateChanged(datePickerEnd:)), for: .valueChanged)
        datePickerStart.addTarget(self, action: #selector(dateChanged(datePickerStart:)), for: .valueChanged)
        datePickerDuration.addTarget(self, action: #selector(dateChanged(datePickerDuration:)), for: .valueChanged)
        
        if let date = self.selectedDate {
              datePickerStart.date = date
              datePickerEnd.date = date
              datePickerDuration.date = date
          }
        
    }
    
    
    @objc func dateChanged(datePickerStart: UIDatePicker) {
        datePickerEnd.date = max(datePickerEnd.date, datePickerStart.date)
        datePickerDuration.date = max(datePickerStart.date, datePickerDuration.date)
        refreshAppearance()

    }
    
    @objc func dateChanged(datePickerEnd: UIDatePicker) {
        datePickerStart.date = min(datePickerStart.date, datePickerEnd.date)
        refreshAppearance()
    }
    
    @objc func dateChanged(datePickerDuration: UIDatePicker) {
        datePickerDuration.date = max(datePickerStart.date, datePickerDuration.date)
        refreshAppearance()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
}
