//
//  MeetData.swift
//  FieldScribe
//
//  Created by Cody Garvin on 10/24/17.
//  Copyright © 2017 OIT. All rights reserved.
//

import Foundation

struct MeetRawData: Codable {
    let href: String
    let rel: [String]
    let offset: Int
    let limit: Int
    let size: Int
    let value: [MeetData]
}

struct MeetData: Codable {
    
    let meetID: Int
    let meetName: String
    let meetDate: Date?
    let meetLocation: String
    let measurementType: MeetMeasurementType
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Private Methods
    public enum CodingKeys : String, CodingKey {
        case meetID = "meetId"
        case meetName = "meetName"
        case meetDate = "meetDate"
        case meetLocation = "meetLocation"
        case measurementType = "measurementType"
    }
}

extension MeetData {
    enum MeetType: String {
        case MiddleSchool = "Middle School"
        case HighSchool = "High School"
        case Collegiate = "Collegiate"
        case Club = "Club"
    }
}

extension MeetData {
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        meetID = try values.decode(Int.self, forKey: .meetID)
        meetName = try values.decode(String.self, forKey: .meetName)
        meetLocation = try values.decode(String.self, forKey: .meetLocation)
        
        // Custom Date Transformation
        let eventDateString = try values.decode(String.self, forKey: .meetDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        meetDate = dateFormatter.date(from: eventDateString)
        
        let measurementTypeString = try values.decode(String.self, forKey: .measurementType)
        if measurementTypeString.lowercased() == MeetMeasurementType.Imperial.rawValue.lowercased() {
            measurementType = MeetMeasurementType.Imperial
        } else if measurementTypeString.lowercased() == MeetMeasurementType.Metric.rawValue.lowercased() {
            measurementType = MeetMeasurementType.Metric
        } else {
            measurementType = MeetMeasurementType.Vertical
        }
    }
    
    func encode(to encoder: Encoder) throws {
        // TODO: build out encoding for all object properties
        
        /* needed properties
         let meetID: Int
         let meetName: String
         let meetDate: Date?
         let meetLocation: String
         let measurementType: MeetMeasurementType
         */
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(true, forKey: .meetID)
        
        try container.encode(true, forKey: .meetName)
        
        try container.encode(meetDate, forKey: .meetDate)
        
        try container.encode(true, forKey: .meetLocation)
        
        if (measurementType == .Imperial) {
            try container.encode(true, forKey: .measurementType)
        } else {
            try container.encode(false, forKey: .measurementType)
        }
        try container.encode(meetDate, forKey: .meetDate)
        
    }
}


extension MeetData {
        
    static func fetchMeets(completion: @escaping (_: [MeetData]) -> ()) {
        
        let url = URL(string: "https://fieldscribeapi2017.azurewebsites.net/meets/?limit=100&orderBy=meetDate%20desc")
        FieldScribeNetworkController.sharedInstance.getRequest(url:url!, query: nil) { (data, error) in
           
            // print data
            print("Data: \(data!)")
            
            if let data = data {
                
                //Implement JSON decoding and parsing
                do {
                    // Decode retrived data with JSONDecoder and passing type of Athlete object
                    let meetRawData = try JSONDecoder().decode(MeetRawData.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        completion(meetRawData.value)
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
            }
        }
    }
}
