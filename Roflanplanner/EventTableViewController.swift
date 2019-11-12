//
//  EventTableViewController.swift
//  Roflanplanner
//
//  Created by Admin on 01.11.2019.
//  Copyright © 2019 fefu. All rights reserved.
//

import UIKit

class EventTableViewController: UITableViewController, UITextViewDelegate {

    var event : Event?
    var creatingNewEvent : Bool = false

    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var eventNameCell: UITableViewCell!
    
    @IBOutlet weak var eventDetailsTextView: UITextView!
    @IBOutlet weak var eventNameTextView: UITextView!
    
    @IBAction func clickedEditButton(_ sender: Any) {
        if editButton.title == "Done" {
            eventNameCell.isHidden = true
            eventNameTextView.isEditable = false
            eventDetailsTextView.isEditable = false
            
            
            

            if eventDetailsTextView.text.isEmpty {
                eventDetailsTextView.text = "No details"
            }
            
            editButton.title = "Edit"
            navigationBar.title = event?.name

        } else {
            eventNameCell.isHidden = false
            eventNameTextView.isEditable = true
            eventDetailsTextView.isEditable = true
            
            eventDetailsTextView.text = event?.details
            
            editButton.title = "Done"
            navigationBar.title = "Editing"

        }
        print("Edit pressed")

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        navigationBar.title = event?.name
        eventDetailsTextView.text = event?.details
        if eventDetailsTextView.text.isEmpty {
            eventDetailsTextView.text = "No details"
        }
        eventNameTextView.text = event?.name
        print("Event table view loaded")
        print(creatingNewEvent)
    }
    

    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
        //tableView.reload
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
