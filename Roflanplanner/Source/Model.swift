//
//  Model.swift
//  Roflanplanner
//
//  Created by Admin on 19/07/2019.
//  Copyright © 2019 fefu. All rights reserved.
//

import Foundation
import JZCalendarWeekView

enum objectType {
    case event
    case instance
    case pattern
}

let DayByIndex = [ "MO", "TU", "WE", "TH", "FR", "SA", "SU"]

let IndexByDay = [
    "MO" : 0,
    "TU" : 1,
    "WE" : 2,
    "TH" : 3,
    "FR" : 4,
    "SA" : 5,
    "SU" : 6,
]

let freqByIndex = [ "NONE", "DAILY", "WEEKLY", "MONTHLY", "YEARLY"]

let IndexByFreq = [
    "DAILY"  : 1,
    "WEEKLY" : 2,
    "MONTHLY": 3,
    "YEARLY" : 4,
]

class CalendarModel {
    
    var events: [Int64:Event] = [:]
    var instanes: [Int:[EventInstance]] = [:]
    var patterns: [Int64:Pattern] = [:]
    var JZevents: [Date:[JZBaseEvent]] = [:]
    
    
    static func convertToDate(_ s1970: Int64) -> Date {
        
        return Date(timeIntervalSince1970: Double(s1970) / 1000)

    }

    func fetchEvents(completion: @escaping () -> Void) {
        Api.get(type: objectType.event) { result in
            switch result {
            case .success(let json):
                print("success fetch events")
                print(json)
                let jsonArray = json as! [String: Any]
                let data = jsonArray["data"] as! Array<[String: Any]>
                self.events.removeAll()
                for jsonEvent in data {
                    //let event = Event(json: jsonEvent)
                    let jsonEvent = try! JSONSerialization.data(withJSONObject: jsonEvent)
                    let decoder = JSONDecoder()
                    let event = try! decoder.decode(Event.self, from: jsonEvent)
                    self.events[event.id!] = event
                    //print(event.id)
                    //print("appended")
                }
                completion()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchInstances(completion: @escaping () -> Void) {
        Api.get(type: objectType.instance) { result in
            switch result {
            case .success(let jsonArray):
                print("success fetch instances")
                print(jsonArray)
                let jsonArray = jsonArray as! [String: Any]
                let data = jsonArray["data"] as! Array<[String: Any]>
                self.instanes.removeAll()
                for jsonInstance in data {
                    //let instance = EventInstance(json: jsonInstance)
                    let jsonInstance = try! JSONSerialization.data(withJSONObject: jsonInstance)
                    let decoder = JSONDecoder()
                    let instance = try! decoder.decode(EventInstance.self, from: jsonInstance)
                    let date = CalendarModel.convertToDate(instance.started_at!)
                    let format = DateFormatter()
                    format.dateFormat = "yyyyMMdd"
                    let formattedDate = Int(format.string(from: date))!
                    
                    self.JZevents[date, default: []].append(JZBaseEvent.init(id: "0", startDate: CalendarModel.convertToDate(instance.started_at!), endDate: CalendarModel.convertToDate(instance.ended_at!)))
                    self.instanes[formattedDate, default: []].append(instance)

                    //print(formattedDate)
                    //print("appended")
                }
                completion()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchPatterns(completion: @escaping () -> Void) {
        Api.get(type: objectType.pattern) { result in
            switch result {
            case .success(let json):
                print("success fetch patterns")
                print(json)
                let jsonArray = json as! [String: Any]
                let data = jsonArray["data"] as! Array<[String: Any]>
                self.patterns.removeAll()
                for jsonPattern in data {
                    //let event = Event(json: jsonEvent)
                    let jsonPattern = try! JSONSerialization.data(withJSONObject: jsonPattern)
                    let decoder = JSONDecoder()
                    let pattern = try! decoder.decode(Pattern.self, from: jsonPattern)
                    self.patterns[pattern.event_id!] = pattern
                    //print(event.id)
                    //print("appended")
                }
                completion()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteEvent(eventInstance: EventInstance, completion: @escaping () -> Void) {
        let event = events[eventInstance.event_id!]!
        Api.delete(type: .pattern, id: patterns[event.id!]!.id!) { _ in
            Api.delete(type: .event, id: event.id!) { _ in
                completion()
            }
        }
        
    }
    
    static func patchEvent(event: Event, pattern: Pattern, completion: @escaping () -> Void ) {
        
        Api.patch(type: .event, id: event.id!, object: event) { _ in
            Api.patch(type: .pattern ,id: pattern.id!, object: pattern) { _ in
                completion()
            }
        }
        
    }
    
    static func postEvent(event: Event, pattern: Pattern, completion: @escaping () -> Void ) {
        Api.post(type: .event, object: event) { result in
            switch result {
                
            case .success(let json):
                print(json)
                let jsonArray = json as! [String: Any]
                let data = jsonArray["data"] as! Array<[String: Any]>
                let jsonEvent = data.first!
                let id = jsonEvent["id"] as! Int64
                pattern.event_id = id
                Api.post(type: .pattern, object: pattern) { result in
                    switch result {
                        
                    case .success(let json):
                        print(json)
                        completion()

                    case .failure(let error):
                        print(error)
                    }
                }
                
            case .failure(let error):
                print(error)
                
            }
        }
        
    }
    
    func postShare(event: Event, completion: @escaping (String) -> Void ) {
        var params : Array<[String : Any]> = []
        let pattern = self.patterns[event.id!]!
        params = [
            ["action" : "READ", "entity_id" : event.id!, "entity_type" : "EVENT"],
            ["action" : "UPDATE", "entity_id" : event.id!, "entity_type" : "EVENT"],
            ["action" : "DELETE", "entity_id" : event.id!, "entity_type" : "EVENT"],
            ["action" : "READ", "entity_id" : pattern.id!, "entity_type" : "PATTERN"],
            ["action" : "UPDATE", "entity_id" : pattern.id!, "entity_type" : "PATTERN"],
            ["action" : "DELETE", "entity_id" : pattern.id!, "entity_type" : "PATTERN"]
        ]
        
        Api.postShare(parameters: params, completion:{ result in
            completion(result.components(separatedBy: "/").last!)
        })
        
    }
    
    func getShare(token: String, completion: @escaping () -> Void ) {
        Api.getShare(token: token) { result in
            switch result {
            case .success(let json):
                print("success apply token")
                print(json)
                completion()
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
}

protocol JsonEncodable {
    
    func encode() -> [String : Any]
    
}

class Event : JsonEncodable, Codable {
    
    var created_at: Int64?
    var details: String?
    var id: Int64?
    var location: String?
    var name: String?
    var owner_id: String?
    var status: String?
    var updated_at: Int64?
    
    func encode() -> [String : Any] {
        let encoder = JSONEncoder()
        return try! JSONSerialization.jsonObject(with: try! encoder.encode(self)) as! [String : Any]
    }
    
}

class EventInstance : JsonEncodable, Codable {
    
    var event_id: Int64?
    var pattern_id: Int64?
    var started_at: Int64?
    var ended_at: Int64?
    
    func encode() -> [String : Any] {
        let encoder = JSONEncoder()
        return try! JSONSerialization.jsonObject(with: try! encoder.encode(self)) as! [String : Any]
    }
    
}

class Pattern : JsonEncodable, Codable {
    
    var created_at: Int64?
    var duration: Int64?
    var ended_at: Int64?
    var event_id: Int64?
    var exrule: String?
    var exrules: Array<[String : String]>?
    var id: Int64?
    var rrule: String?
    var started_at: Int64?
    var timezone: String?
    var updated_at: Int64?
    
    func encode() -> [String : Any] {
        let encoder = JSONEncoder()
        return try! JSONSerialization.jsonObject(with: try! encoder.encode(self)) as! [String : Any]
    }
    
    func getWeekdays() -> [Int] {
        if rrule?.isEmpty ?? true { return [] }
        var array : [Int] = []
        let rule = rrule!.components(separatedBy: ";")[1]
        for (key, value) in IndexByDay {
            if rule.contains(key) {
                array.append(value)
            }
        }
        print("rrule ", rrule!)
        return array
    }
    
    func setRRuleWeekly(from days: [Int], interval: Int){
        var weekdays = ""
        for index in days {
            weekdays += "\(DayByIndex[index]),"
        }
        if weekdays.isEmpty {
            self.rrule = ""
        } else {
            weekdays.popLast()
            self.rrule = "FREQ=WEEKLY;BYDAY=\(weekdays);INTERVAL=\(interval)"
        }
    }
    
    func getFreq() -> Int {
        if let rrule = self.rrule {
            let rules = rrule.components(separatedBy: ";")
            for rule in rules {
                if rule.contains("FREQ=") {
                    let freq = String(rule.dropFirst(5))
                    print("freq:", freq)
                    return(IndexByFreq[freq]!)
                }
            }
        }
        return 0
    }
    
    func getInterval() -> Int {
        if let rrule = self.rrule {
            let rules = rrule.components(separatedBy: ";")
            for rule in rules {
                if rule.contains("INTERVAL=") {
                    let interval = String(rule.dropFirst(9))
                    print("interval:", interval)
                    return(Int(interval)!)
                }
            }
        }
        return 1
    }
    
}
