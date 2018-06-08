//
//  BarHeightData.swift
//  FieldScribe
//
//  Created by Cody Garvin on 3/13/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import Foundation

enum BarHeightMark: String {
    case Success = "O"
    case Miss = "X"
    case Pass = "P"
}

struct BarHeightDataArray: Codable {
    let eventID: Int
    let heights: Array<BarHeightData>
    
    private enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case heights = "heights"
    }
}

struct BarHeightMarksArray: Codable {
    let eventID: Int
    let entryID: Int
    let marks: Array<BarHeightData>
    
    private enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case entryID = "entryId"
        case marks = "marks"
    }
}

struct BarHeightData: Codable {
    
    var heightNumber: Int?
    var attemptNumber: Int?
    var feet: Int?
    var inches: Double?
    var meters: Decimal?
    var marks: Array<BarHeightMark>?
    var marksString: String {
        get {
            
            guard let marks = marks else {
                if let foundString = _marksString {
                    return foundString
                } else {
                    return ""
                }
            }
            
            var tempString = ""
            for mark in marks {
                tempString.append(mark.rawValue)
            }
            return tempString
        }
        set {
            _marksString = newValue
        }
    }
    
    private
    var _marksString: String? = nil
    
    init(heightNumber: Int?, attemptNumber: Int?, feet: Int?, inches: Double?, meters: Decimal?) {
        self.heightNumber = heightNumber
        self.attemptNumber = attemptNumber
        self.feet = feet
        self.inches = inches
        self.meters = meters
    }
    
    var measurementType: MeetMeasurementType {
        get {
            var returnValue = MeetMeasurementType.Imperial
            if let tempMeters = meters {
                if tempMeters > 0 {
                    returnValue = .Metric
                }
            }
            return returnValue
        }
    }
    
    func prettyStringRepresentation() -> String? {
        
        var returnValue: String? = nil
        if let feet = feet, var inches = inches {
            // Total inches
            inches = inches + (Double(feet) * 12)
            returnValue = MeetMeasurementType.convertInches(toHumanString: inches)
        } else if let meters = meters {
            let centimeters = meters * 100 // convert to cm
            returnValue = MeetMeasurementType.convertCentimeters(toMetersHumanString: centimeters)
        }
        
        return returnValue
    }
    
    
    /// Takes an existing _marksString and makes sure there is matching mark
    /// types to go along with it.
    mutating func cleanMarks() {
        
        if marks == nil {
            if let foundString = _marksString {
                // Fill in missing marks
                if foundString.count > 0 {
                    var tempBarMarks = Array<BarHeightMark>()
                    for char in foundString {
                        if let mark = BarHeightMark(rawValue: String(char)) {
                            tempBarMarks.append(mark)
                        }
                    }
                    self.marks = tempBarMarks
                }
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Private Methods
    private enum CodingKeys : String, CodingKey {
        case heightNumber = "heightNum"
        case height = "height"
        case feet = "feet"
        case inches = "inches"
        case meters = "meters"
        case mark = "mark"
        case attemptNumber = "attemptNum"
    }
}

extension BarHeightData {
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        heightNumber = try values.decodeIfPresent(Int.self, forKey: .heightNumber)
        attemptNumber = try values.decodeIfPresent(Int.self, forKey: .attemptNumber)
        _marksString = try values.decodeIfPresent(String.self, forKey: .mark)
        if let measurementHeight = try values.decodeIfPresent(String.self, forKey: .height) {
        
            // Split the format to match 5-04 and store those appropriately
            var splitHeights = measurementHeight.components(separatedBy: "-")
            if splitHeights.count > 1 {
                feet = Int(splitHeights[0]) ?? 0
                inches = Double(splitHeights[1]) ?? 0
            } else {
                feet = 0
                inches = 0
            }
            
            if feet == 0 && inches == 0 && measurementHeight.contains(".") {
                meters = Decimal(string: measurementHeight)
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(heightNumber, forKey: .heightNumber)
        try container.encode(attemptNumber, forKey: .attemptNumber)
        try container.encodeIfPresent(feet, forKey: .feet)
        try container.encodeIfPresent(inches, forKey: .inches)
        try container.encodeIfPresent(meters, forKey: .meters)
        try container.encodeIfPresent(marksString, forKey: .mark)
    }
}

extension BarHeightData {
    func measurementFromUnits() -> Decimal? {
        if let feet = feet, let inches = inches {
            return Decimal(MeetMeasurementType.convertToInchesWithFeet(feet, inches: inches))
        } else if let meters = meters {
            return meters
        }
        
        return nil
    }
}

extension BarHeightData {
    
    
    static func postBarHeights(_ eventData: EventData, completion: @escaping (_ error: Error?) -> Void) {
        
        guard let heights = eventData.barHeights else { return }
        
        let type = eventData.measurementParams.measurementType
        
        let url = URL(string: "https://fieldscribeapi2017.azurewebsites.net/barheights/\(type.lowercased())")
        
        let distanceData = BarHeightDataArray(eventID: eventData.eventID, heights: heights)
        let jsonEncoder = JSONEncoder()
        do {
            let data = try jsonEncoder.encode(distanceData)
            
            FieldScribeNetworkController.sharedInstance.postRequest(url: url!, body: data) { (data, error) in
                if error == nil {
                    print("Completed Horizontal Score Entry")
                    completion(nil)
                } else {
                    print("error: \(error!.localizedDescription)")
                    completion(error)
                }
            }
        } catch {
            print("Unable to send marks")
        }
    }
}

func ==(lhs: BarHeightData, rhs: BarHeightData) -> Bool {
    
    var returnValue = false
    if let lhsFeet = lhs.feet, let lhsInches = lhs.inches, let rhsFeet = rhs.feet, let rhsInches = rhs.inches {
        if lhsFeet == rhsFeet && lhsInches == rhsInches {
            returnValue = true
        }
    } else if let lhsMeters = lhs.meters, let rhsMeters = rhs.meters {
        if lhsMeters == rhsMeters {
            returnValue = true
        }
    }
    
    return returnValue
}

func <(lhs: BarHeightData, rhs: BarHeightData) -> Bool {
    
    var returnValue = false
    if let lhsFeet = lhs.feet, let lhsInches = lhs.inches, let rhsFeet = rhs.feet, let rhsInches = rhs.inches {
        
        let lhsConvertedInches = MeetMeasurementType.convertToInchesWithFeet(lhsFeet, inches: lhsInches)
        let rhsConvertedInches = MeetMeasurementType.convertToInchesWithFeet(rhsFeet, inches: rhsInches)
        if lhsConvertedInches < rhsConvertedInches {
            returnValue = true
        }
    } else if let lhsMeters = lhs.meters, let rhsMeters = rhs.meters {
        if lhsMeters < rhsMeters {
            returnValue = true
        }
    }
    
    return returnValue
}
