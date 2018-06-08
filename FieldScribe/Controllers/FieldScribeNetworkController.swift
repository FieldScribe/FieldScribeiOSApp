//
//  FieldScribeNetworkController.swift
//  FieldScribe
//
//  Created by Cody Garvin on 10/24/17.
//  Copyright © 2017 OIT. All rights reserved.
//

import Foundation

class FieldScribeNetworkController {
    
    static let sharedInstance = FieldScribeNetworkController()
    
    func getRequest(url: URL, query: String?, completion: @escaping (_ jsonData: Data?, _ error: Error?) -> Void) {
        
        // Start with the url session that will handle executing our request
        let getSession = URLSession(configuration: URLSessionConfiguration.default)
        
        // Start the data request and handle appropriately
        getSession.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse {
                
                if 200 ... 299 ~= response.statusCode {
                    DispatchQueue.main.async {
                        completion(data, error)
                    }
                } else {
                    print("Response: \(response.statusCode)")
                }
            }
        }.resume()
    }
    
    func postRequest(url: URL, body: Data, completion: @escaping (_ jsonData: Data?, _ error: Error?) -> Void) {
            
        let postSession = URLSession(configuration: URLSessionConfiguration.default)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = body
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        postSession.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse {
                
                if 200 ... 299 ~= response.statusCode {
                    DispatchQueue.main.async {
                        completion(data, error)
                    }
                } else {
                    print("Response: \(response.statusCode)")
                }
            }
            
            }.resume()
        
        
    }
}

extension Dictionary {
    var queryString: String? {
        return self.reduce("") { "\($0!)\($1.0)=\($1.1)&" }
    }
}
