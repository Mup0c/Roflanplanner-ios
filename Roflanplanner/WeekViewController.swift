//
//  WeekViewController.swift
//  Roflanplanner
//
//  Created by Admin on 19.11.2019.
//  Copyright © 2019 fefu. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class WeekViewController: UIViewController {

    var JZEvents : [Date:[JZBaseEvent]]!
    var events = [Date(): [JZBaseEvent.init(id: "1", startDate: Date(timeIntervalSince1970: Double(1575927415)), endDate: Date(timeIntervalSince1970: Double(1575905815)))]]
    var str : String!
    
    @IBOutlet var calendar: JZBaseWeekView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.setupCalendar(numOfDays: 7,
        setDate: Date(),
        allEvents: events,
        scrollType: .pageScroll,
        firstDayOfWeek: .Monday)
        
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.dismiss(animated: true, completion:{})
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
