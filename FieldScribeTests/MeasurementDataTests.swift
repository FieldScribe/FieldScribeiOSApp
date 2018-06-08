//
//  MeasurementDataTests.swift
//  FieldScribeTests
//
//  Created by Cody Garvin on 5/17/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import XCTest
@testable import FieldScribe

class MeasurementDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConvertMetersToInches() {
        
        let result = MeetMeasurementType.convertMeters(toInches: 32)
        XCTAssert(result == 1259.84, "Result was \(result)")
    }
    
    func testConvertInchesToMeters() {
        let result = MeetMeasurementType.convertInches(toMeters: 46)
        XCTAssert(result == 1.15)
    }

    ////
    // Test English
    func testConvertInchesToHumanString() {
        var result = MeetMeasurementType.convertInches(toHumanString: 46)
        XCTAssert(result == "3'10.00\"")
        
        result = MeetMeasurementType.convertInches(toHumanString: 46.54)
        XCTAssert(result == "3'10.54\"")
        
        result = MeetMeasurementType.convertInches(toHumanString: 46.54, withPrecision: false)
        XCTAssert(result == "3'10\"")
    }
    
    func testConvertFormattedStringToInches() {
        var result = MeetMeasurementType.convertFormattedString(toInches: "19-1")
        XCTAssert(result == 229)
        
        result = MeetMeasurementType.convertFormattedString(toInches: "19-1.54")
        XCTAssert(result == 229.54)
        
        result = MeetMeasurementType.convertFormattedString(toInches: "19-1.54", withPrecision: false)
        XCTAssert(result == 229)
    }
    
    func testConvertHumanStringToInches() {
        var result = MeetMeasurementType.convertHumanString(toInches: "19'1\"")
        XCTAssert(result == 229)
        
        result = MeetMeasurementType.convertHumanString(toInches: "19'1.54\"")
        XCTAssert(result == 229.54)
        
        result = MeetMeasurementType.convertHumanString(toInches: "19'1.54\"", withPrecision: false)
        XCTAssert(result == 229)
        
        result = MeetMeasurementType.convertHumanString(toInches: "11.54\"")
        XCTAssert(result == 11.54)

        result = MeetMeasurementType.convertHumanString(toInches: "11.54\"", withPrecision: false)
        XCTAssert(result == 11)

    }

    
    func testConvertInchesToFormattedString() {
        var result = MeetMeasurementType.convertInches(toFormattedString: 229)
        XCTAssert(result == "19-1.00")
        
        result = MeetMeasurementType.convertInches(toFormattedString: 229.54)
        XCTAssert(result == "19-1.54")
        
        result = MeetMeasurementType.convertInches(toFormattedString: 229.54, withPrecision: false)
        XCTAssert(result == "19-1")
    }
    
    func testConvertInchesToFeetAndInches() {
        var result = MeetMeasurementType.convertInches(toFeetAndInches: 229)
        XCTAssert(result.feet == 19)
        XCTAssert(result.inches == 1.00)
        
        result = MeetMeasurementType.convertInches(toFeetAndInches: 229.54)
        XCTAssert(result.feet == 19)
        XCTAssert(result.inches == 1.54)
        
        result = MeetMeasurementType.convertInches(toFeetAndInches: 229.54, withPrecision: false)
        XCTAssert(result.feet == 19)
        XCTAssert(result.inches == 1)
    }
    
    func testConvertFeetAndInchesToInches() {
        var result = MeetMeasurementType.convertToInchesWithFeet(6, inches:5)
        XCTAssert(result == 77.00)
        
        result = MeetMeasurementType.convertToInchesWithFeet(6, inches: 5.54)
        XCTAssert(result == 77.54)
        
        result = MeetMeasurementType.convertToInchesWithFeet(6, inches: 5.54, withPrecision: false)
        XCTAssert(result == 77)
    }
    
    ////
    // Test Metric
    func testConvertCentimetersToHumanString() {
        var result = MeetMeasurementType.convertCentimeters(toHumanString: 46)
        XCTAssert(result == "46.00 cm", "Value was: \(result)")
        
        result = MeetMeasurementType.convertCentimeters(toHumanString: 46.54)
        XCTAssert(result == "46.54 cm")
        
        result = MeetMeasurementType.convertCentimeters(toHumanString: 46.54, withPrecision: false)
        XCTAssert(result == "46 cm")
    }
    
    func testConvertCentimetersToMetersHumanString() {
        var result = MeetMeasurementType.convertCentimeters(toMetersHumanString: 46)
        XCTAssert(result == "0.46 m")
        
        result = MeetMeasurementType.convertCentimeters(toMetersHumanString: 46.54)
        XCTAssert(result == "0.47 m")
        
        result = MeetMeasurementType.convertCentimeters(toMetersHumanString: 46.54, withPrecision: false)
        XCTAssert(result == "0 m")
        
        result = MeetMeasurementType.convertCentimeters(toMetersHumanString: 146.54)
        XCTAssert(result == "1.47 m")
    }
    
    func testConvertHumanStringToCentimeters() {
        var result = MeetMeasurementType.convertHumanString(toCentimeters: "46")
        XCTAssert(result == 46.00)
        
        result = MeetMeasurementType.convertHumanString(toCentimeters: "46.54")
        XCTAssert(result == 46.54)

        result = MeetMeasurementType.convertHumanString(toCentimeters: "46.54", withPrecision: false)
        XCTAssert(result == 46)
    }

    func testConvertCentimetersToFormattedString() {
        var result = MeetMeasurementType.convertCentimeters(toFormattedString: 29)
        XCTAssert(result == "29.00")
        
        result = MeetMeasurementType.convertCentimeters(toFormattedString: 229.54)
        XCTAssert(result == "229.54")
        
        result = MeetMeasurementType.convertCentimeters(toFormattedString: 229.54, withPrecision: false)
        XCTAssert(result == "229")
    }
    
    func testConvertCentimetersToCMDecimal() {
        var result = MeetMeasurementType.convertCentimeters(toCMDecimal: 19.91)
        XCTAssert(result.cm == 19)
        if let _ = result.decimal {
            XCTAssert(result.decimal! == 0.91, "Result was: \(result.decimal!)")
        }
        
        result = MeetMeasurementType.convertCentimeters(toCMDecimal: 229.54)
        XCTAssert(result.cm == 229)
        if let _ = result.decimal {
            XCTAssert(result.decimal! == 0.54, "Result was: \(result.decimal!)")
        }

        result = MeetMeasurementType.convertCentimeters(toCMDecimal: 229.54, withPrecision: false)
        XCTAssert(result.cm == 229)
        XCTAssertNil(result.decimal)
    }
}
