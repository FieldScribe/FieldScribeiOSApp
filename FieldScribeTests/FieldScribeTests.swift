//
//  FieldScribeTests.swift
//  FieldScribeTests
//
//  Created by Cody Garvin on 10/24/17.
//  Copyright © 2017 OIT. All rights reserved.
//

import XCTest
@testable import FieldScribe

class FieldScribeTests: XCTestCase {
    
    var meetData: MeetData?
    var athleteData: AthleteData?
    
    override func setUp() {
        super.setUp()
        
        // set a date to instantiate MeetData class, any will do
        let date = Date(timeIntervalSince1970: 0)
        
        // populate meet data for test
        meetData = MeetData(meetID: 01,
                            meetName: "Imperial Meet Name",
                            meetDate: date,
                            meetLocation: "Lincoln",
                            measurementType: .Imperial)
        
        // populate athlete data for test
//        athleteData = AthleteData(athleteID: <#T##Int#>, meetID: <#T##Int#>, entryID: <#T##Int#>, eventID: <#T##Int#>, competitionNumber: <#T##Int#>, firstName: <#T##String#>, lastName: <#T##String#>, teamName: <#T##String#>, markType: <#T##String#>, marks: <#T##Array<DistanceData>#>)
        athleteData = AthleteData(athleteID: 01, meetID: 01, entryID: 01, eventID: 01,
                                  competitionNumber: 500, firstName: "Jonsey",
                                  lastName: "Testerfield", teamName: "Franklin",
                                  markType: MeetMeasurementType.Imperial.rawValue,
                                  marks: Array<DistanceData>())
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // test instantiation of meet object
    func testMeetDataInstantiation() {
        
        let date = Date(timeIntervalSince1970: 0)
        
        // Imperial Meet Test
        XCTAssert(meetData?.meetID == 1, "meetID data error on MeetData(...) instantiation")
        XCTAssert(meetData?.meetName == "Imperial Meet Name", "meetName data error on MeetData(...) instantiation")
        XCTAssert(meetData?.meetDate == date, "meetDate data error on MeetData(...) instantiation")
        XCTAssert(meetData?.meetLocation == "Lincoln", "meetLocation data error on MeetData(...) instantiation")
        XCTAssert(meetData?.measurementType == .Imperial, "measurmentType data error on MeetData(...) instantiation")
        
    }
    
    func testAthleteDataInstantiation() {
        
        // Athlete Test
        XCTAssert(athleteData?.athleteID == 1, "meetID data error on MeetData(...) instantiation")
        XCTAssert(athleteData?.competitionNumber == 500, "meetName data error on MeetData(...) instantiation")
        XCTAssert(athleteData?.firstName == "Jonsey", "meetDate data error on MeetData(...) instantiation")
        XCTAssert(athleteData?.lastName == "Testerfield", "meetLocation data error on MeetData(...) instantiation")
        XCTAssert(athleteData?.teamName == "Franklin", "measurmentType data error on MeetData(...) instantiation")
        
    }
    
    // test Encode
    func testEncodeJSON() {
        let meetDataEncoded = try? JSONEncoder().encode(meetData)
        let athleteDataEncoded = try? JSONEncoder().encode(athleteData)
        //print(meetDataEncoded)
        
        if let data = meetDataEncoded {
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let json = json {
                print(json)
            }
        }
        
        if let data = athleteDataEncoded {
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let json = json {
                print(json)
            }
        }
        
    }
    
    // test MeetData Decode
    func testMeetDataFromJSON() {
        
        if let filepath = Bundle(for: type(of: self)).path(forResource: "meetData", ofType: "mock") {
            do {
                let contents = try String(contentsOfFile: filepath)
                print(contents)
                
                let contentsData = contents.data(using: .utf8)
                if let data = contentsData {
                    print(data)
                    let meetData = try JSONDecoder().decode(MeetData.self, from: data)
                    print(meetData)
                    
                    // XCTAssertions for JSON data
                    /*
                     {
                     "href": "https://fieldscribeapi2017.azurewebsites.net/meets/3",
                     "meetId": 3,
                     "meetName": "Pacific Preview 2017",
                     "meetDate": "2017-03-11T00:00:00",
                     "meetLocation": "Pacific University",
                     "measurementType": true
                     }
                     */
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    let testDate = dateFormatter.date(from: "2017-03-11T00:00:00")
                    
                    XCTAssert(meetData.meetID == 3, "meetID error on JSON decode")
                    XCTAssert(meetData.meetName == "Pacific Preview 2017", "meetName error on JSON decode")
                    XCTAssert(meetData.meetDate == testDate, "meetDate error on JSON decode")
                    XCTAssert(meetData.meetLocation == "Pacific University", "meetLocation error on JSON decode")
                    XCTAssert(meetData.measurementType == MeetMeasurementType.Metric, "measurementType error on JSON decode")
                    
                }
                
            } catch {
                // contents could not be loaded
                XCTFail("JSON meetData.mock test file could not be loaded \(error)")
            }
        } else {
            // example.txt not found!
            XCTFail("JSON meetData.mock test file not found")
        }
    }
    
    
    // test AthleteData Decode
    func testAthleteDataFromJSON() {
        
        if let filepath = Bundle(for: type(of: self)).path(forResource: "athleteData", ofType: "mock") {
            do {
                let contents = try String(contentsOfFile: filepath)
                print(contents)
                
                let contentsData = contents.data(using: .utf8)
                if let data = contentsData {
                    print(data)
                    let athleteRawData = try JSONDecoder().decode(AthleteRawData.self, from: data)
                    print(athleteRawData)
                    
                    // XCTAssertions for JSON data
                    /*
                     "value": [
                     {
                     "href": "https://fieldscribeapi2017.azurewebsites.net/athlete/471",
                     "events": {
                     "href": "https://fieldscribeapi2017.azurewebsites.net/meets/3/athletes/471/events"
                     },
                     "athleteId": 471,
                     "meetId": 3,
                     "compNum": 400,
                     "firstName": "Adelaine",
                     "lastName": "Ahmasuk",
                     "teamName": "Linfield",
                     
                     TODO: gender testing, not working currently
                     "gender": "F
                     },
                    */
                    
                    if let athleteData = athleteRawData.value.first {
                        XCTAssert(athleteData.athleteID == 471, "athleteID error on JSON decode")
                        XCTAssert(athleteData.competitionNumber == 400, "athleteID error on JSON decode")
                        XCTAssert(athleteData.firstName == "Adelaine", "firstName error on JSON decode")
                        XCTAssert(athleteData.lastName == "Ahmasuk", "lastName error on JSON decode")
                        XCTAssert(athleteData.teamName == "Linfield", "teamName error on JSON decode")
                        
                        // fullName() test
                        let name: String = athleteData.fullName()
                        print(name)
                        
                        
                        // attempting to implement athlete fetch tests
                        
//                        var athleteTable: UITableView!
//
//                        athleteTable.dataSource = athleteData
//                        athleteTable.register(AthleteTableViewCell.self, forCellReuseIdentifier: "AthleteCell")
//
//                        // Fetch an athlete!
//                        AthleteData.fetchAthletes { (data) in
//                            // Store off the athleteData
//                            self.athleteData = data
//
//                            // Reload the world
//                            self.athleteTable.reloadData()
//                        }
                        
                        
                        
                        
                        
                    }
                    
 
                }
                
            } catch {
                // athleteData.mock could not be loaded
                XCTFail("JSON athleteData.mock test file could not be loaded \(error)")
            }
        } else {
            // athleteData.mock not found!
            XCTFail("JSON athleteData.mock test file not found")
        }
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

