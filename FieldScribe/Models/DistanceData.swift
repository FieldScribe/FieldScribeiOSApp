//
//  DistanceData.swift
//  FieldScribe
//
//  Created by Cody Garvin on 5/9/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import Foundation


struct DistanceData: Codable {
    let attemptNumber: Int
    var mark: String? = nil
    var meters: Decimal? = nil
    var feet: Int? = nil
    var inches: Double? = nil
    var wind: Bool? = nil
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Private Methods
    private enum CodingKeys : String, CodingKey {
        case attemptNumber = "attemptNum"
        case mark = "mark"
        case meters = "meters"
        case feet = "feet"
        case inches = "inches"
        case wind = "wind"
    }
}

extension DistanceData {
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        attemptNumber = try values.decode(Int.self, forKey: CodingKeys.attemptNumber)
        mark = try values.decode(String?.self, forKey: CodingKeys.mark)
        meters = try values.decodeIfPresent(Decimal.self, forKey: CodingKeys.meters)
        feet = try values.decodeIfPresent(Int.self, forKey: CodingKeys.feet)
        inches = try values.decodeIfPresent(Double.self, forKey: CodingKeys.inches)
        wind = try values.decode(Bool?.self, forKey: CodingKeys.wind)
        
        // Check our values
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(attemptNumber, forKey: .attemptNumber)
        try container.encode(mark, forKey: .mark)
        try container.encode(wind, forKey: .wind)
        try container.encode(meters, forKey: .meters)
        try container.encode(feet, forKey: .feet)
        try container.encode(inches, forKey: .inches)
    }
    
    mutating func cleanupMarkForType(_ markType: String) {
        
        guard let tempMark = mark else { return }
        
        if markType == MeetMeasurementType.Imperial.rawValue {
            // Parse it as english
            if feet == nil || inches == nil {
                // Convert to total inches
                if let totalInches = MeetMeasurementType.convertFormattedString(toInches: tempMark) {
                    let finalScore = MeetMeasurementType.convertInches(toFeetAndInches: totalInches)
                    self.feet = finalScore.feet
                    self.inches = finalScore.inches
                }
            }
        } else if markType == MeetMeasurementType.Metric.rawValue {
            // Convert to centimeters from meters
            let metersValue = Decimal(string: tempMark)
            self.meters = metersValue
        }
    }
}

struct DistanceDataArray: Codable {
    let entryID: Int
    let eventID: Int
    let marks: Array<DistanceData>
    
    private enum CodingKeys: String, CodingKey {
        case entryID = "entryID"
        case eventID = "eventID"
        case marks = "marks"
    }
}
