//
//  Measurement.swift
//  FieldScribe
//
//  Created by Cody Garvin on 3/12/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import Foundation

enum MeetMeasurementType: String {
    case Metric = "Metric"
    case Imperial = "English"
    case Vertical = "Vertical"
    
    static func convertMeters(toInches meters: Decimal) -> Decimal {
        var total = meters * Decimal(39.3701)
        var tempTotal = total
        NSDecimalRound(&tempTotal, &total, 2, .plain)
        return tempTotal
    }
    
    static func convertInches(toMeters inches: Decimal) -> Decimal {
        var total = (inches * 0.025 * 100) / 100
        var tempTotal = total
        NSDecimalRound(&tempTotal, &total, 2, .plain)
        return tempTotal
    }
    
    // MARK: - Imperial
    static func convertInches(toHumanString inches: Double, withPrecision: Bool = true) -> String {
        let feet = Int(inches / 12)
        let finalInches = Int(inches) % 12
        let decimalInches = inches.truncatingRemainder(dividingBy: 1)
        
        var returnString = "\(feet)'\(finalInches)\""
        if withPrecision {
            let returnInches = Double(finalInches) + decimalInches
            returnString = "\(feet)'\(String(format: "%.2f", returnInches))\""
        }
        
        return returnString
    }
    
    static func convertFormattedString(toInches string: String, withPrecision: Bool = true) -> Double? {
        
        var returnValue: Double? = nil
        let metrics = string.split(separator: "-")
        if metrics.count > 1 {
            let feetToInches = metrics[0]
            let inches = metrics[1]
            returnValue = Double((feetToInches as NSString).integerValue * 12 + (inches as NSString).integerValue)
            
            if withPrecision {
                if let _ = returnValue {
                    let decimalInches = (inches as NSString).doubleValue.truncatingRemainder(dividingBy: 1)
                    returnValue = returnValue! + decimalInches
                }
            }
        }
        
        return returnValue
    }
    
    static func convertHumanString(toInches string: String, withPrecision: Bool = true) -> Double? {
        
        var returnValue: Double? = nil
        
        if string.contains("'") {
            // Contains feet
            let metrics = string.split(separator: "'")
            
            if metrics.count > 1 {
                let feetToInches = metrics[0]
                let tempInches = metrics[1]
                var inches: String? = nil
                if tempInches.contains("\"") {
                    // Remove it inch indicator
                    inches = String(tempInches.replacingOccurrences(of: "\"", with: ""))
                    
                    if let inches = inches {
                        returnValue = Double((feetToInches as NSString).integerValue * 12 + (inches as NSString).integerValue)
                        
                        if withPrecision {
                            if let _ = returnValue {
                                let decimalInches = (inches as NSString).doubleValue.truncatingRemainder(dividingBy: 1)
                                returnValue = returnValue! + decimalInches
                            }
                        }
                    }
                }
            }
        } else if string.contains("\"") {
            // Contains inches
            let inches = String(string.replacingOccurrences(of: "\"", with: ""))
            
            returnValue = Double((inches as NSString).integerValue)
            
            if withPrecision {
                if let _ = returnValue {
                    let decimalInches = (inches as NSString).doubleValue.truncatingRemainder(dividingBy: 1)
                    returnValue = returnValue! + decimalInches
                }
            }
        }

        return returnValue
    }
    
    static func convertInches(toFormattedString inches: Double, withPrecision: Bool = true) -> String? {
        
        let feet = Int(inches) / 12
        var finalInches = Double(Int(inches) % 12)
        let decimalInches = inches.truncatingRemainder(dividingBy: 1)
        
        var returnString = "\(feet)-\(Int(finalInches))"
        if withPrecision {
            finalInches = finalInches + Double(decimalInches)
            returnString = "\(feet)-\(String(format: "%.2f", finalInches))"
        }
        
        return returnString
        
    }
    
    static func convertInches(toFeetAndInches inches: Double, withPrecision: Bool = true) -> (feet: Int, inches: Double) {
        let feet = Int(inches) / 12
        var returnInches = Double(Int(inches) % 12)
        
        if withPrecision {
            returnInches = returnInches + ((inches.truncatingRemainder(dividingBy: 1) * 100).rounded() / 100)
        }
        return (Int(feet), returnInches)
    }
    
    static func convertToInchesWithFeet(_ feet: Int, inches: Double, withPrecision: Bool = true) -> Double {
        
        var returnValue = Double(feet * 12 + Int(inches))
        
        if withPrecision {
            let decimalInches = inches.truncatingRemainder(dividingBy: 1)
            returnValue = returnValue + decimalInches
        }
        
        return returnValue
    }
    
    // MARK: - Metric
    static func convertCentimeters(toHumanString cm: Decimal, withPrecision: Bool = true) -> String {
        
        var returnString = "\((cm as NSNumber).intValue) cm"
        if withPrecision {
            let formatter = self.precisionFormatter()
            if let string = formatter.string(from: (cm as NSNumber)) {
                returnString = "\(string) cm"
            }
        }
        
        return returnString
    }
    
    static func convertCentimeters(toMetersHumanString cm: Decimal, withPrecision: Bool = true) -> String {
        
        var returnString = ""
        if withPrecision {
            let formatter = self.precisionFormatter()
            if let string = formatter.string(from: ((cm / 100) as NSNumber)) {
                returnString = "\(string) m"
            }
        } else {
            if cm < 100 {
                returnString = "0 m"
            } else {
                returnString = "\(((cm / 100) as NSNumber).intValue) m"
            }
        }
        
        return returnString
    }
    
    static func convertHumanString(toCentimeters string: String, withPrecision: Bool = true) -> Decimal? {
        
        var returnValue: Decimal? = nil
        let cm = Decimal(string: string)
        
        if var tempTotal = cm, var tempCM = cm {
            NSDecimalRound(&tempTotal, &tempCM, 2, .plain)
            returnValue = tempTotal
        }
        
        if !withPrecision {
            if let _ = returnValue {
                returnValue = Decimal((returnValue! as NSNumber).intValue)
            }
        }
        
        return returnValue
    }
    
    static func convertCentimeters(toFormattedString cm: Decimal, withPrecision: Bool = true) -> String? {

        var returnString = "\((cm as NSNumber).intValue)"
        if withPrecision {
            let formatter = precisionFormatter()
            if let string = formatter.string(from: (cm as NSNumber)) {
                returnString = "\(string)"
            }
        }
        
        return returnString

    }
    
    static func convertCentimeters(toCMDecimal cm: Decimal, withPrecision: Bool = true) -> (cm: Int, decimal: Decimal?) {
        let returnCM = (cm as NSNumber).intValue
        var decimal: Decimal? = nil
        
        if withPrecision {
            var tempDecimal = cm
            var holderDecimal = Decimal(0)
            NSDecimalRound(&holderDecimal, &tempDecimal, 2, .plain)
            decimal = holderDecimal - Decimal(returnCM)
        }
        return (returnCM, decimal)
    }
    
    static func precisionFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.roundingMode = .up
        return formatter
    }
}
