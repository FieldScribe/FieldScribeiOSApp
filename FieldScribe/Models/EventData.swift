//
//  EventData.swift
//  FieldScribe
//
//  Created by Cody Garvin on 3/6/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import Foundation

struct EventRawData: Codable {
    let href: String
    let rel: [String]
    let offset: Int
    let limit: Int
    let size: Int
    let value: [EventData]
}

struct EventData: Codable {
    
    let eventID: Int
    let meetID: Int
    let eventNumber: Int
    let roundNumber: Int
    let flightNumber: Int
    var eventName: String
    var eventSubName: String
    let measurementParams: MeasurementParams
    var barHeights: Array<BarHeightData>? = nil
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Private Methods
    private enum CodingKeys : String, CodingKey {
        case eventID = "eventId"
        case meetID = "meetId"
        case eventNumber = "eventNum"
        case roundNumber = "roundNum"
        case flightNumber = "flightNum"
        case eventName = "eventName"
        case measurementParams = "params"
        case barHeights = "barHeights"
        case heights = "heights"
    }
}

extension EventData {
    enum EventType: String {
        case Vertical = "Vertical"
        case Horizontal = "Horizontal"
    }
}

extension EventData {
    
    init(from decoder: Decoder) throws {
        
        // Custom Date Transformation
        let values = try decoder.container(keyedBy: CodingKeys.self)
        eventID = try values.decode(Int.self, forKey: .eventID)
        meetID = try values.decode(Int.self, forKey: .meetID)
        eventNumber = try values.decode(Int.self, forKey: .eventNumber)
        flightNumber = try values.decode(Int.self, forKey: .flightNumber)
        roundNumber = try values.decode(Int.self, forKey: .roundNumber)
        eventName = try values.decode(String.self, forKey: .eventName)
        eventSubName = ""
//        measurementParams = try values.decode([String: AnyJSONType].self, forKey: .measurementParams)
        measurementParams = try values.decode(MeasurementParams.self, forKey: .measurementParams)
        // TODO: Consider changing measurementParams to a model instead of
        // dictionary that doesn't have type inference
        if measurementParams.eventType == "Vertical" {
            barHeights = try values.decode(Array<BarHeightData>.self, forKey: .barHeights)
        }
        
        // Clean up eventName if it has parens
        if eventName.contains("(") {
            
            // Find index of first (
            let splitEventName = eventName.split(separator: "(")
            
            if (splitEventName.count > 1) {
                eventName = String(splitEventName[0])
                
                let splitSubName = String(splitEventName[1]).split(separator: ")")
                if splitSubName.count > 0 {
                    eventSubName = String(splitSubName[0])
                }
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventID, forKey: .eventID)
        if let barHeights = barHeights {
            try container.encode(barHeights, forKey: .heights)
        }
    }
    
    mutating func sortBarHeights() {
        
        guard var tempBarHeights = barHeights else { return }
        
        // First get them in the correct order
        tempBarHeights = tempBarHeights.sorted(by: {
            if let left = $0.meters, let right = $1.meters {
                return left < right
            } else if let leftFeet = $0.feet, let leftInches = $0.inches, let rightFeet = $1.feet, let rightInches = $1.inches {
                let leftTotal = MeetMeasurementType.convertToInchesWithFeet(leftFeet, inches: leftInches)
                let rightTotal = MeetMeasurementType.convertToInchesWithFeet(rightFeet, inches: rightInches)
                return leftTotal < rightTotal
            } else {
                return true
            }
        })
        
        // Second renumber them
        var finalSortedArray = Array<BarHeightData>()
        for (index, barHeight) in tempBarHeights.enumerated() {
            var copiedBarHeight = barHeight
            copiedBarHeight.heightNumber = index+1
            copiedBarHeight.attemptNumber = index+1
            finalSortedArray.append(copiedBarHeight)
        }
        self.barHeights = finalSortedArray
    }
}

extension EventData {
    
    static func fetchEventsForMeet(_ meetID: Int, completion: @escaping (_: [EventData]) -> ()) {
        
        let url = URL(string: "https://fieldscribeapi2017.azurewebsites.net/meets/\(meetID)/events")
        FieldScribeNetworkController.sharedInstance.getRequest(url:url!, query: nil) { (data, error) in
            
            // print data
            print("Data: \(data!)")
            
            if let data = data {
                
                //Implement JSON decoding and parsing
                do {
                    // Decode retrived data with JSONDecoder and passing type of Athlete object
                    let eventRawData = try JSONDecoder().decode(EventRawData.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        completion(eventRawData.value)
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
            }
        }
    }
}

struct MeasurementParams: Codable {
    let maximum: Double
    let precision: Double
    let measurementType: String
    let eventType: String
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Private Methods
    private enum CodingKeys : String, CodingKey {
        case maximum = "maximum"
        case precision = "precision"
        case measurementType = "measurementType"
        case eventType = "eventType"
    }
    
    init(from decoder: Decoder) throws {
        
        // Custom Date Transformation
        let values = try decoder.container(keyedBy: CodingKeys.self)
        maximum = try values.decode(Double.self, forKey: .maximum)
        precision = try values.decode(Double.self, forKey: .precision)
        measurementType = try values.decode(String.self, forKey: .measurementType)
        eventType = try values.decode(String.self, forKey: .eventType)
    }
}

