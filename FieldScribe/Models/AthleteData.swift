//
//  AthleteData.swift
//  FieldScribe
//
//  Created by Cody Garvin on 10/24/17.
//  Copyright © 2017 OIT. All rights reserved.
//

import Foundation

struct AthleteRawData: Codable {
    let href: String? = nil
    let rel: [String]? = nil
    let offset: Int? = nil
    let limit: Int? = nil
    let size: Int? = nil
    let value: [AthleteData]
    
    private enum CodingKeys: String, CodingKey {
        case href
        case rel
        case offset
        case limit
        case size
        case value
    }
}

struct AthleteData: Codable {
    var athleteID: Int? = 0
    var meetID: Int? = 0
    var entryID: Int? = 0
    var eventID: Int? = 0
    let competitionNumber: Int
    let firstName: String
    let lastName: String
    let teamName: String
    
    /// The measurement type that dictates the format to use when displaying
    /// marks.
    let markType: String?
    
    /// The mark that keeps track of the users best in human readable format.
    var bestMark: String? = nil
    
    /// Horizontal marks that keep track of an athletes scores for a specific
    /// event.
    var marks: Array<DistanceData>?
    
    /// Vertical marks kept in ascending order at all times to avoid running through the entire
    /// array to match server bar heights.
    var verticalMarks: Array<BarHeightData>?
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Private Methods
    private enum CodingKeys : String, CodingKey {
        case athleteId = "athleteId"
        case meetId = "meetId"
        case entryId = "entryId"
        case eventId = "eventId"
        case competitionNumber = "compNum"
        case firstName = "firstName"
        case lastName = "lastName"
        case teamName = "teamName"
        case markType = "markType"
        case marks = "marks"
    }
    
    init(athleteID: Int, meetID: Int, entryID: Int, eventID: Int, competitionNumber: Int, firstName: String, lastName: String, teamName: String, markType: String, marks: Array<DistanceData>) {
        self.athleteID = athleteID
        self.entryID = entryID
        self.eventID = eventID
        self.competitionNumber = competitionNumber
        self.firstName = firstName
        self.lastName = lastName
        self.teamName = teamName
        self.markType = markType
        self.marks = marks
    }
    
    init(from decoder: Decoder) throws {
        
        // Custom Date Transformation
        let values = try decoder.container(keyedBy: CodingKeys.self)
        athleteID = try values.decodeIfPresent(Int.self, forKey: .athleteId)
        meetID = try values.decodeIfPresent(Int.self, forKey: .meetId)
        eventID = try values.decodeIfPresent(Int.self, forKey: .eventId)
        entryID = try values.decodeIfPresent(Int.self, forKey: .entryId)
        
        competitionNumber = try values.decode(Int.self, forKey: .competitionNumber)
        firstName = try values.decode(String.self, forKey: .firstName)
        lastName = try values.decode(String.self, forKey: .lastName)
        teamName = try values.decode(String.self, forKey: .teamName)
        markType = try values.decodeIfPresent(String.self, forKey: .markType)
        marks = try values.decodeIfPresent(Array<DistanceData>.self, forKey: .marks)
        verticalMarks = try values.decodeIfPresent(Array<BarHeightData>.self, forKey: .marks)
    }
    
    func encode(to encoder: Encoder) throws {
        
        //        var container = encoder.container(keyedBy: CodingKeys.self)
        //        if (measurementType == .Imperial) {
        //            try container.encode(true, forKey: .measurementType)
        //        } else {
        //            try container.encode(false, forKey: .measurementType)
        //        }
        //        try container.encode(meetDate, forKey: .meetDate)
        
    }
}

extension AthleteData {
    
    func fullName() -> String {
        return "\(firstName) \(lastName)"
    }
    
    func properName() -> String {
        return "\(lastName) \(firstName)"
    }
    
    mutating func cleanupMarks() {
        var copiedMarks = Array<DistanceData>()
        guard let markType = markType, let marks = marks else { return }
        for var data in marks {
            data.cleanupMarkForType(markType)
            copiedMarks.append(data)
        }
        if !copiedMarks.isEmpty {
            self.marks = copiedMarks
        }
    }
    
    mutating func cleanupVerticalMarks() {
        var copiedMarks = Array<BarHeightData>()
        guard let verticalMarks = verticalMarks else { return }
        for var data in verticalMarks {
            data.cleanMarks()
            copiedMarks.append(data)
        }
        if !copiedMarks.isEmpty {
            self.verticalMarks = copiedMarks
        }
    }
    
    
    /// Add a horizontal mark to athlete data. Let the logic figure out how best
    /// to place it.
    ///
    /// - Parameters:
    ///   - mark: The number of the horizontal mark in either centimeters or inches.
    ///   - type: The measurement type in either "Metric" or "English"
    ///   - index: Optionally mark where the mark should be inserted.
    mutating func addMark(_ mark: Int, type: String, index: Int?) {
        
        if marks == nil {
            marks = Array<DistanceData>()
        }
        
        // First clean up marks
        self.cleanupMarks()
        
        guard var marks = marks else { return }
        
        // First check if we are adding it to a specific place
        if type == MeetMeasurementType.Imperial.rawValue {
            let (feet, inches) = MeetMeasurementType.convertInches(toFeetAndInches: Double(mark))
            let updatedMark = MeetMeasurementType.convertInches(toFormattedString: Double(mark))
            
            if let index = index {
                if index >= 0 && index < 3 {
                    let builtMark = DistanceData(attemptNumber: index, mark: updatedMark, meters: nil, feet: feet, inches: inches, wind: nil)
                    if marks.count > index {
                        marks[index] = builtMark
                    } else {
                        marks.append(builtMark)
                    }
                }
            } else {
                // Find the first available position
                let builtMark = DistanceData(attemptNumber: marks.count+1, mark: updatedMark, meters: nil, feet: feet, inches: inches, wind: nil)
                marks.append(builtMark)
            }
        } else if type == MeetMeasurementType.Metric.rawValue {
            let meters = Decimal(mark) / 100
            let updatedMark = MeetMeasurementType.convertCentimeters(toFormattedString: meters)
            
            if let index = index {
                if index >= 0 && index < 3 {
                    let builtMark = DistanceData(attemptNumber: index, mark: updatedMark, meters: Decimal(mark) / 100, feet: nil, inches: nil, wind: nil)
                    if marks.count > index {
                        marks[index] = builtMark
                    } else {
                        marks.append(builtMark)
                    }
                }
            } else {
                let builtMark = DistanceData(attemptNumber: marks.count+1, mark: updatedMark, meters: Decimal(mark) / 100, feet: nil, inches: nil, wind: nil)
                marks.append(builtMark)
            }
        }
        
        self.marks = marks
        
        self.normalizeBestMark()
    }
    
    
    /// Adds a vertical mark to the proper height if necessary
    ///
    /// - Parameters:
    ///   - markMeasurement: The measurement in either inches or meters
    ///   - markType: The mark associated with P, X, O
    ///   - measurementType: The unit of measurement type
    ///   - index: Where the markType should be placed inside the measurement data found
    /// - Returns: The index at which the mark was placed
    mutating func addVerticalMark(_ markMeasurement: Decimal, markType: BarHeightMark, measurementType: MeetMeasurementType, index: Int?) -> Int {
        
        var foundIndex = -1
        
        // First clean up marks
        self.cleanupVerticalMarks()
        
        // Check that athete data isn't empty
        if verticalMarks == nil {
            verticalMarks = Array<BarHeightData>()
        }
        
        guard var tempVerticalMarks = verticalMarks else { return foundIndex }
        
        // See if any barheights match this mark so we can update it
        var insertOneAtIndex = 0
        for (index, heightData) in tempVerticalMarks.enumerated() {
            
            if let feet = heightData.feet, let inches = heightData.inches {
                let (tempFeet, tempInches) = MeetMeasurementType.convertInches(toFeetAndInches: Double(truncating: markMeasurement as NSNumber))
                if tempFeet == feet && tempInches == inches {
                    // We found our mark
                    foundIndex = index
                    break
                } else if Decimal(MeetMeasurementType.convertToInchesWithFeet(feet, inches: inches)) < markMeasurement {
                    insertOneAtIndex = insertOneAtIndex + 1
                }
            } else if let meters = heightData.meters {
                if markMeasurement == meters {
                    // We found our mark
                    foundIndex = index
                    break
                } else if meters < markMeasurement {
                    insertOneAtIndex = insertOneAtIndex + 1
                }
            }
        }
        
        // Create a new one at the proper index if we didn't find one
        if foundIndex <= -1 {
            if measurementType == .Imperial {
                let (tempFeet, tempInches) = MeetMeasurementType.convertInches(toFeetAndInches: Double(truncating: markMeasurement as NSNumber))
                let createdBarHeightData = BarHeightData(heightNumber: insertOneAtIndex+1, attemptNumber: insertOneAtIndex+1, feet: tempFeet, inches: tempInches, meters: nil)
                tempVerticalMarks.insert(createdBarHeightData, at: insertOneAtIndex)
                foundIndex = insertOneAtIndex
            } else {
                let createdBarHeightData = BarHeightData(heightNumber: insertOneAtIndex+1, attemptNumber: insertOneAtIndex+1, feet: nil, inches: nil, meters: markMeasurement)
                tempVerticalMarks.insert(createdBarHeightData, at: insertOneAtIndex)
                foundIndex = insertOneAtIndex
            }
        }
        
        
        // If we found our measurement, update the measurement with the proper mark
        if foundIndex >= 0 {
            // Found index needs updating
            var markToUpdate = tempVerticalMarks[foundIndex]
            if markToUpdate.marks == nil {
                markToUpdate.marks = Array<BarHeightMark>()
            }
            guard var tempMarks = markToUpdate.marks else { return foundIndex }
            
            if let index = index {
                if index >= 0 && index < 3 {
                    if tempMarks.count > index {
                        tempMarks[index] = markType
                    } else {
                        tempMarks.append(markType)
                    }
                }
            } else {
                if tempMarks.count < 3 {
                    tempMarks.append(markType)
                } else {
                    // TODO: Possibly convert to error handling with throwing an error
                    // for now do noting if we already have 3
                }
            }
            
            // Update the measurement with the new updated marks
            markToUpdate.marks = tempMarks
            
            // Put the mark back into the array
            tempVerticalMarks[foundIndex] = markToUpdate
        }
        
        // Save it off
        self.verticalMarks = tempVerticalMarks
        
        // Return the index at which we used
        return foundIndex
    }
    
    
    /// Calculate best mark and store it off so we do not have to calculate
    /// it many times.
    mutating func normalizeBestMark() {
        
        guard let marks = marks else { return }
        
        // Get out if we don't have a mark to calculate
        if marks.isEmpty {
            return
        }
        
        // Figure out the best mark in the marks
        
        var tempBestMark: Decimal = 0
        var tempBestMarkString: String? = nil
        
        for tempMark in marks {
            
            guard let mark = tempMark.mark else { continue }
            
            if markType == MeetMeasurementType.Imperial.rawValue {
                if let totalInches = MeetMeasurementType.convertFormattedString(toInches: mark) {
                    let totalDecimalInches = Decimal(totalInches)
                    if totalDecimalInches > tempBestMark {
                        tempBestMark = totalDecimalInches
                        tempBestMarkString = MeetMeasurementType.convertInches(toHumanString: totalInches)
                    }
                }
            } else if markType == MeetMeasurementType.Metric.rawValue {
                if var totalCM = MeetMeasurementType.convertHumanString(toCentimeters: mark) {
                    totalCM = totalCM * 100
                    if totalCM > tempBestMark {
                        tempBestMark = totalCM
                        tempBestMarkString = MeetMeasurementType.convertCentimeters(toHumanString: totalCM)
                    }
                }
                
            }
        }
        
        if tempBestMark > 0 {
            bestMark = tempBestMarkString
        }
    }
}

extension AthleteData {
    
    
    static func fetchAthletes(completion: @escaping (_: [AthleteData]) -> ()) {
        let url = URL(string: "https://fieldscribeapi2017.azurewebsites.net/athletes/")
        FieldScribeNetworkController.sharedInstance.getRequest(url:url!, query: nil) { (data, error) in
            // print data
            print("Data: \(data!)")
            
            if let data = data {
                
                //Implement JSON decoding and parsing
                do {
                    // Decode retrived data with JSONDecoder and passing type of Athlete object
                    let rawData = try JSONDecoder().decode(AthleteRawData.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        completion(rawData.value)
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
            }
        }
    }
    
    static func fetchAthletesForEvent(_ eventID: Int, completion: @escaping (_: [AthleteData]) -> ()) {
        let url = URL(string: "https://fieldscribeapi2017.azurewebsites.net/events/\(eventID)/entries")
        FieldScribeNetworkController.sharedInstance.getRequest(url:url!, query: nil) { (data, error) in
            // print data
            print("Data: \(data!)")
            
            if let data = data {
                
                //Implement JSON decoding and parsing
                do {
                    // Decode retrived data with JSONDecoder and passing type of Athlete object
                    let rawData = try JSONDecoder().decode(AthleteRawData.self, from: data)
                    
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        completion(rawData.value)
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
            }
        }
    }
    
    static func postMarks(_ marks:Array<DistanceData>, eventID: Int, entryID: Int, type: String, completion: @escaping (_ error: Error?) -> Void) {
        let url = URL(string: "https://fieldscribeapi2017.azurewebsites.net/marks/horizontal/\(type.lowercased())")
        
        let distanceData = DistanceDataArray(entryID: entryID, eventID: eventID, marks: marks)
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
    
    static func postBarHeightMarks(_ heights: Array<BarHeightData>, eventID: Int, entryID: Int, completion: @escaping (_ error: Error?) -> Void) {
        let url = URL(string: "https://fieldscribeapi2017.azurewebsites.net/marks/vertical")
        
        let verticalData = BarHeightMarksArray(eventID: eventID, entryID: entryID, marks: heights)
        let jsonEncoder = JSONEncoder()
        do {
            let data = try jsonEncoder.encode(verticalData)
            
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
