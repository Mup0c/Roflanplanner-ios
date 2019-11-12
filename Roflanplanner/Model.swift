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
        Api.get(type: getType.instances) { result in
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


class Event : Codable {
    
    var created_at: Int64?
    var details: String?
    var id: Int64?
    var location: String?
    var name: String?
    var owner_id: String?
    var status: String?
    var updated_at: Int64?
    
}

class EventInstance : Codable{
    
    var event_id: Int64?
    var pattern_id: Int64?
    var started_at: Int64?
    var ended_at: Int64?
    
}

class EventPattern : Codable {
    
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
    
}

class Api {
    
    static let baseUrl = "http://frrcode.com:9040/api/v1"
    
    static func get(type: getType, completion: @escaping (Result<Any>) -> Void) {
        var url = self.baseUrl
        switch type {
        case .events:
            url += "/events"
        case .instances:
            url += "/events/instances"
        }
        Alamofire.request(url, headers: ["X-Firebase-Auth": "tester"])
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
    
    static func patch(id: Int64, parameters: Parameters, completion: @escaping (Result<Any>) -> Void) {
        var url = self.baseUrl
        url += "/events"  //todo: switch
        url += String(id)

        Alamofire.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default,
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
