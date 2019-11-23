//
//  Api.swift
//  Roflanplanner
//
//  Created by Admin on 21.11.2019.
//  Copyright © 2019 fefu. All rights reserved.
//

import Foundation
import Alamofire


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
