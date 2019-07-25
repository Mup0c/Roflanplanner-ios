//
//  Model.swift
//  Roflanplanner
//
//  Created by Admin on 19/07/2019.
//  Copyright © 2019 fefu. All rights reserved.
//

import Foundation
import Alamofire


class Data {
    var events: [Event] = []
    
    
    func fetchEvents(completion: @escaping () -> Void) {
        Api.getEvents() { result in
            switch result {
            case .success(let jsonArray):
                print("success fetch events")
                print(jsonArray)
                let jsonArray = jsonArray as! [String: Any]
                let data = jsonArray["data"] as! Array<[String: Any]>
                self.events.removeAll()
                for jsonEvent in data {
                    self.events.append(Event(json: jsonEvent))
                    //print("appended")
                }
                completion()
                
            case .failure(let error):
                print(error)
            }
            
        }
    }


    
}

class EventInstance {
    
}

class Pattern {
    
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

class Api {
    
    static func getEvents(completion: @escaping (Result<Any>) -> Void) {

        Alamofire.request(
            "http://planner.skillmasters.ga/api/v1/events",
            headers: ["X-Firebase-Auth": "serega_mem"])
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
