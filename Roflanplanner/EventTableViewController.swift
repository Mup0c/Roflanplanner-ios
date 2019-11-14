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
    
    var editingState : Bool!
    
    var datePickerStart : UIDatePicker!
    var datePickerEnd : UIDatePicker!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var eventNameCell: UITableViewCell!
    
    @IBOutlet weak var eventDetailsTextView: UITextView!
    @IBOutlet weak var eventNameTextView: UITextView!
    
    @IBOutlet weak var dateTextStart: UITextView!
    @IBOutlet weak var dateTextEnd: UITextView!
    
    @IBAction func clickedEditButton(_ sender: Any) {
        
        editingState = !editingState

        if !editingState {
            saveData()
        }
        refreshAppearance()

        print("Edit pressed")
        
    }
    
    
    func saveData() {
        let willCreateNewEvent = event == nil
        event = event ?? Event()
        pattern = pattern ?? Pattern()

        event.details = eventDetailsTextView.text
        event.name = eventNameTextView.text
        pattern.started_at = Int64(datePickerStart.date.timeIntervalSince1970 * 1000)
        pattern.ended_at = Int64(datePickerEnd.date.timeIntervalSince1970 * 1000)
        if willCreateNewEvent {
            editButton.isEnabled = false
            Data.postEvent(event: event, pattern: pattern) {
                self.dismiss(animated: true, completion: {})
                if #available(iOS 13.0, *) {
                    let navCtrlPresCtrl = self.navigationController!.presentationController!
                    navCtrlPresCtrl.delegate?.presentationControllerDidDismiss?(navCtrlPresCtrl)
                }
            }
        } else {
            Data.patchEvent(event: event, pattern: pattern)
        }
    }
    
    func refreshAppearance() {
        
        
        if !editingState {
            editButton.title = "Edit"
            navigationBar.title = event?.name
            eventNameTextView.text = event?.name
            eventDetailsTextView.text = event?.details
            
            datePickerStart.date = Date(timeIntervalSince1970: (Double(pattern.started_at!) / 1000))
            datePickerEnd.date = Date(timeIntervalSince1970: (Double(pattern.ended_at!) / 1000))
            dateTextStart.text = DateFormatter.localizedString(from: datePickerStart.date, dateStyle: .full, timeStyle: .short)
            dateTextEnd.text = DateFormatter.localizedString(from: datePickerEnd.date, dateStyle: .full, timeStyle: .short)
            
            if eventDetailsTextView.text.isEmpty {
                eventDetailsTextView.text = "No details"
            }

            eventNameCell.isHidden = true
            eventNameTextView.isEditable = false
            eventDetailsTextView.isEditable = false
            dateTextEnd.isSelectable = false
            dateTextStart.isSelectable = false

        } else {
            editButton.title = "Done"
            navigationBar.title = "Editing"
            
            eventNameCell.isHidden = false
            eventNameTextView.isEditable = true
            eventDetailsTextView.isEditable = true
            dateTextEnd.isSelectable = true
            dateTextStart.isSelectable = true
            
            if pattern == nil {
                
            }
            
            eventDetailsTextView.text = event?.details

        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        editingState = event == nil
        initDatePickers()

        refreshAppearance()
        
        print("Event table view loaded")
    }
    
    func initDatePickers() {
        datePickerEnd = UIDatePicker()
        datePickerStart = UIDatePicker()
        datePickerEnd.datePickerMode = .dateAndTime
        datePickerStart.datePickerMode = .dateAndTime
        dateTextStart.inputView = datePickerStart
        dateTextEnd.inputView = datePickerEnd
        
        datePickerEnd.addTarget(self, action: #selector(dateChanged(datePickerEnd:)), for: .valueChanged)
        datePickerStart.addTarget(self, action: #selector(dateChanged(datePickerStart:)), for: .valueChanged)
        
        
    }
    
    
    @objc func dateChanged(datePickerStart: UIDatePicker) {
        datePickerEnd.date = max(datePickerEnd.date, datePickerStart.date)
        dateTextStart.text = DateFormatter.localizedString(from: datePickerStart.date, dateStyle: .full, timeStyle: .short)
        dateTextEnd.text = DateFormatter.localizedString(from: datePickerEnd.date, dateStyle: .full, timeStyle: .short)

    }
    
    @objc func dateChanged(datePickerEnd: UIDatePicker) {
        datePickerStart.date = min(datePickerStart.date, datePickerEnd.date)
        dateTextStart.text = DateFormatter.localizedString(from: datePickerStart.date, dateStyle: .full, timeStyle: .short)
        dateTextEnd.text = DateFormatter.localizedString(from: datePickerEnd.date, dateStyle: .full, timeStyle: .short)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    // MARK: - Table view data source


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}