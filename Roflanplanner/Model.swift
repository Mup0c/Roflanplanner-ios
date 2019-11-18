//
//  Model.swift
//  Roflanplanner
//
//  Created by Admin on 19/07/2019.
//  Copyright © 2019 fefu. All rights reserved.
//

import Foundation
import Alamofire

enum objectType {
    case event
    case instance
    case pattern
}

class Data {
    
    var events: [Int64:Event] = [:]
    var instanes: [Int:[EventInstance]] = [:]
    var patterns: [Int64:Pattern] = [:]

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
    
    static func patchEvent(event: Event, pattern: Pattern) {
        
        Api.patch(type: .event, id: event.id!, object: event) { _ in
            Api.patch(type: .pattern ,id: pattern.id!, object: pattern) { _ in }
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
        params.append([:])
        params[0]["action"] = "READ"
        params[0]["entity_id"] = event.id!
        params[0]["entity_type"] = "EVENT"
        
        params.append([:])
        params[1]["action"] = "UPDATE"
        params[1]["entity_id"] = event.id!
        params[1]["entity_type"] = "EVENT"
        params.append([:])

        params[2]["action"] = "DELETE"
        params[2]["entity_id"] = event.id!
        params[2]["entity_type"] = "EVENT"
        params.append([:])

        params[3]["action"] = "READ"
        params[3]["entity_id"] = self.patterns[event.id!]!.id!
        params[3]["entity_type"] = "PATTERN"
        params.append([:])

        params[4]["action"] = "UPDATE"
        params[4]["entity_id"] = self.patterns[event.id!]!.id!
        params[4]["entity_type"] = "PATTERN"
        params.append([:])

        params[5]["action"] = "DELETE"
        params[5]["entity_id"] = self.patterns[event.id!]!.id!
        params[5]["entity_type"] = "PATTERN"

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
    
    func setRRuleWeekly(from days: [Int]){
        var dayStr = ""
        for i in days {
            switch i {
            case 0:
                dayStr += "MO,"
                
            case 1:
                dayStr += "TU,"

            case 2:
                dayStr += "WE,"

            case 3:
                dayStr += "TH,"

            case 4:
                dayStr += "FR,"

            case 5:
                dayStr += "SA,"

            case 6:
                dayStr += "SU,"
                
            case -1:
                dayStr += "SU,"

            default:
                continue
            }
        }
        if dayStr.isEmpty {
            self.rrule = ""
        } else {
            dayStr.popLast()
            self.rrule = "FREQ=WEEKLY;BYDAY=\(dayStr);INTERVAL=1"
        }
    }
    
}

class Api {
    
    static let baseUrl = "http://frrcode.com:9040/api/v1"
    static let headers = ["X-Firebase-Auth": "serega_mem"]
    
    static func buildUrl(type: objectType) -> String {
        
        var url = self.baseUrl
        
        switch type {
        case .event:
            url += "/events"
        case .instance:
            url += "/events/instances"
        case .pattern:
            url += "/patterns"
        }
        
        return url
    }
    
    static func get(type: objectType, completion: @escaping (Result<Any>) -> Void) {
        
        let url = self.buildUrl(type: type)
        
        Alamofire.request(url, headers: headers)
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
    
    static func patch(type: objectType, id: Int64, object: JsonEncodable, completion: @escaping (Result<Any>) -> Void) {
        
        var url = self.buildUrl(type: type)
        url += "/" + String(id)
        
        Alamofire.request(url, method: .patch, parameters: object.encode(), encoding: JSONEncoding.default,
                          headers: headers)
            .validate()
            .responseJSON() {  responseJSON in
                switch responseJSON.result {
                case .success(let value):
                    print("patch success")
                    print(url)
                    print(value)
                    completion(.success(value))
                case .failure(let error):
                    print("patch failure")
                    print(url)
                    print(error)
                    completion(.failure(error))
                }
        }
        
    }
    
    static func delete(type: objectType, id: Int64, completion: @escaping (Result<Any>) -> Void) {
        
        var url = self.buildUrl(type: type)
        url += "/" + String(id)
        
        Alamofire.request(url, method: .delete, headers: headers)
            .validate()
            .responseJSON() {  responseJSON in
                switch responseJSON.result {
                case .success(let value):
                    print("delete success")
                    print(url)
                    print(value)
                    completion(.success(value))
                case .failure(let error):
                    print("delete failure")
                    print(url)
                    print(error)
                    completion(.failure(error))
                }
        }
        
    }
    
    static func post(type: objectType, object: JsonEncodable, completion: @escaping (Result<Any>) -> Void) {
        
        var url = self.buildUrl(type: type)
        
        if type == .pattern {
            let pattern = object as! Pattern
            url += "?event_id=" + String(pattern.event_id!)
        }
        
        Alamofire.request(url, method: .post, parameters: object.encode(), encoding: JSONEncoding.default,
                          headers: headers)
            .validate()
            .responseJSON() {  responseJSON in
                switch responseJSON.result {
                case .success(let value):
                    print("post success")
                    print(url)
                    completion(.success(value))
                case .failure(let error):
                    print("post failure")
                    print(url)
                    completion(.failure(error))
                }
        }
    }
    
    static func postShare(parameters: Array<Any>, completion: @escaping (String) -> Void) {
        var url = self.baseUrl
        url += "/share"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(headers["X-Firebase-Auth"], forHTTPHeaderField: "X-Firebase-Auth")

        
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        Alamofire.request(request)
            .validate()
            .responseString(encoding: .utf8){  responseJSON in
                switch responseJSON.result {
                case .success(let value):
                    print("post success")
                    print(url)
                    print(value)
                    
                    completion(value)
                case .failure(let error):
                    print("post failure")
                    print(url)
                    print(error)
                }
        }
    }
    
    static func getShare(token: String, completion: @escaping (Result<Any>) -> Void) {
        var url = self.baseUrl
        url += "/share/" + token
        Alamofire.request(url, headers: headers)
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
