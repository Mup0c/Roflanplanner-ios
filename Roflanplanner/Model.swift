//
//  Model.swift
//  Roflanplanner
//
//  Created by Admin on 19/07/2019.
//  Copyright © 2019 fefu. All rights reserved.
//

import Foundation
import Alamofire

enum getType {
    case events
    case instances
}

class Data {
    
    var events: [Int64:Event] = [:]
    var instanes: [Int:[EventInstance]] = [:]
    
    
    func fetchEvents(completion: @escaping () -> Void) {
        Api.get(type: getType.events) { result in
            switch result {
            case .success(let json):
                print("success fetch events")
                print(json)
                let jsonArray = json as! [String: Any]
                let data = jsonArray["data"] as! Array<[String: Any]>
                self.events.removeAll()
                for jsonEvent in data {
                    let event = Event(json: jsonEvent)
                    self.events[event.id!] = event
                    //print("appended")
                }
                completion()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchInstances(completion: @escaping () -> Void) {
        Api.get(type: getType.instances) { result in
            switch result {
            case .success(let jsonArray):
                print("success fetch instances")
                print(jsonArray)
                let jsonArray = jsonArray as! [String: Any]
                let data = jsonArray["data"] as! Array<[String: Any]>
                self.instanes.removeAll()
                for jsonInstance in data {
                    let instance = EventInstance(json: jsonInstance)
                    let date = Date(timeIntervalSince1970: Double(instance.started_at!) / 1000)
                    let format = DateFormatter()
                    format.dateFormat = "yyyyMMdd"
                    let formattedDate = Int(format.string(from: date))!
                    if self.instanes[formattedDate] != nil {
                        self.instanes[formattedDate]!.append(instance)
                    } else {
                        self.instanes[formattedDate] = [instance]
                    }
                    //print(formattedDate)
                    //print("appended")
                }
                completion()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}


class Event {
    
    var created_at: Int64?
    var details: String?
    var id: Int64?
    var location: String?
    var name: String?
    var owner_id: String?
    var status: String?
    var updated_at: Int64?
    
    init(json: [String: Any]) {
        self.created_at = json["created_at"] as? Int64
        self.details = json["details"] as? String
        self.id = json["id"] as? Int64
        self.location = json["location"] as? String
        self.name = json["name"] as? String
        self.owner_id = json["owner_id"] as? String
        self.status = json["status"] as? String
        self.updated_at = json["updated_at"] as? Int64
        
    }
    
}

class EventInstance {
    
    var event_id: Int64?
    var pattern_id: Int64?
    var started_at: Int64?
    var ended_at: Int64?
    
    init(json: [String: Any]) {
        self.event_id = json["event_id"] as? Int64
        self.ended_at = json["ended_at"] as? Int64
        self.pattern_id = json["pattern_id"] as? Int64
        self.started_at = json["started_at"] as? Int64
        
    }
}

class EventPattern {
    
    var created_at: Int64?
    var duration: Int64?
    var ended_at: Int64?
    var event_id: Int64?
    var exrule: String?
    var id: Int64?
    var rrule: String?
    var started_at: Int64?
    var timezone: String?
    var updated_at: Int64?
    
    init(json: [String: Any]) {
        self.created_at = json["created_at"] as? Int64
        self.duration = json["duration"] as? Int64
        self.ended_at = json["ended_at"] as? Int64
        self.event_id = json["event_id"] as? Int64
        self.exrule = json["exrule"] as? String
        self.id = json["id"] as? Int64
        self.rrule = json["rrule"] as? String
        self.started_at = json["started_at"] as? Int64
        self.timezone = json["timezone"] as? String
        self.updated_at = json["updated_at"] as? Int64
        
    }

    
}

class Api {
    
    static func get(type: getType, completion: @escaping (Result<Any>) -> Void) {
        var baseUrl = "http://frrcode.com:9040/api/v1"
        switch type {
        case .events:
            baseUrl += "/events"
        case .instances:
            baseUrl += "/events/instances"
        }
        Alamofire.request(
            baseUrl,
            headers: ["X-Firebase-Auth": "tester"])
            .validate()
            .responseJSON() {  responseJSON in
                switch responseJSON.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

}
