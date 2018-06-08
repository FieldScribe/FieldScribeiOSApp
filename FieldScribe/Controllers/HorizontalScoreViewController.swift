//
//  HorizontalScoreViewController.swift
//  FieldScribe
//
//  Created by Cody Garvin on 3/12/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import UIKit

class HorizontalScoreViewController: FieldScribeAbstractViewController {
    
    var eventData: EventData? = nil
    var athleteData: AthleteData? = nil
    var headerLabel: FSLabel? = nil
    var scoreInput: FSScoreDial? = nil
    var firstLabel: FSLabel!
    var secondLabel: FSLabel!
    var thirdLabel: FSLabel!
    
    private var selectedIndex: NSInteger = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard let eventData = eventData else { return }
        
        title = "\(eventData.eventName)"
        
        // Add views
        self.buildViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HorizontalScoreViewController {
    
    func buildViews() {
        headerLabel = FSLabel()
        headerLabel!.numberOfLines = 0
        headerLabel!.font = UIFont.boldSystemFont(ofSize: 28.0)
        headerLabel!.textColor = UIColor.fsLightForeground()
        headerLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        headerLabel!.backgroundColor = UIColor.clear
        
        var fieldString = "Field Events"
        if let flightNumber = eventData?.flightNumber {
            fieldString = "Flight \(flightNumber)"
        }
        
        if var subName = eventData?.eventSubName, !subName.isEmpty {
            subName = subName + "\nScore Entry"
            headerLabel!.text = subName
        } else {
            headerLabel!.text = fieldString
        }
        headerLabel!.sizeToFit()
        view.addSubview(headerLabel!)
        
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor.fsDarkGray()
        view.addSubview(backgroundView)
        
        // Build the score dial
        if let measurementType = eventData?.measurementParams.measurementType,
            let maximum = eventData?.measurementParams.maximum {
            
            if measurementType == MeetMeasurementType.Imperial.rawValue {
                // English
                scoreInput = FSScoreDial(frame: CGRect(x: 0, y: 0, width: 298, height: 298), minValue: 0, maxValue: Int(12 * maximum.rounded(.up)), fullRotationValue: 12 * 4)
            } else {
                // Metric
                scoreInput = FSScoreDial(frame: CGRect(x: 0, y: 0, width: 298, height: 298), minValue: 0, maxValue: Int(100 * maximum.rounded(.up)), fullRotationValue: 50)
            }
            
        } else {
            
            // At least give an arbitrary dial
            scoreInput = FSScoreDial(frame: CGRect(x: 0, y: 0, width: 298, height: 298), minValue: 0, maxValue: 12 * 40, fullRotationValue: 12*4)
        }
        
        var centerPoint = view.center
        centerPoint.y = centerPoint.y - 80
        scoreInput?.delegate = self
        scoreInput?.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(scoreInput!)
        
        // Athlete label
        let athleteLabel = FSLabel()
        if let firstName = athleteData?.firstName, let lastName = athleteData?.lastName, let teamName = athleteData?.teamName {
            let mainString = "\(firstName) \(lastName)\n\(teamName)"
            let athleteString = NSMutableAttributedString(string: mainString, attributes: [NSAttributedStringKey.foregroundColor: UIColor.fsLightForeground()])
            athleteString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.bold), range: NSMakeRange(0, "\(firstName) \(lastName)".count))
            athleteLabel.attributedText = athleteString
        }
        athleteLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(athleteLabel)
        
        
        // Best Label
        let bestLabel = FSLabel()
        bestLabel.textAlignment = .right
        bestLabel.attributedText = NSAttributedString(string: "Best:", attributes: [NSAttributedStringKey.foregroundColor: UIColor.fsLightForeground()])
        bestLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(bestLabel)
        
        let label1TapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
        label1TapGesture.numberOfTapsRequired = 1
        
        // First label
        firstLabel = FSLabel()
        firstLabel.attributedText = NSAttributedString(string: "1st:", attributes: [NSAttributedStringKey.foregroundColor: UIColor.fsLightForeground()])
        firstLabel.translatesAutoresizingMaskIntoConstraints = false
        firstLabel.addGestureRecognizer(label1TapGesture)
        firstLabel.isUserInteractionEnabled = true
        firstLabel.tag = 1
        backgroundView.addSubview(firstLabel)
        
        let label2TapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
        label2TapGesture.numberOfTapsRequired = 1
        
        // Second label
        secondLabel = FSLabel()
        secondLabel.attributedText = NSAttributedString(string: "2nd:", attributes: [NSAttributedStringKey.foregroundColor: UIColor.fsLightForeground()])
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        secondLabel.addGestureRecognizer(label2TapGesture)
        secondLabel.isUserInteractionEnabled = true
        secondLabel.tag = 2
        backgroundView.addSubview(secondLabel)
        
        let label3TapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
        label3TapGesture.numberOfTapsRequired = 1
        
        // Third label
        thirdLabel = FSLabel()
        thirdLabel.attributedText = NSAttributedString(string: "3rd:", attributes: [NSAttributedStringKey.foregroundColor: UIColor.fsLightForeground()])
        thirdLabel.translatesAutoresizingMaskIntoConstraints = false
        thirdLabel.addGestureRecognizer(label3TapGesture)
        thirdLabel.isUserInteractionEnabled = true
        thirdLabel.tag = 3
        backgroundView.addSubview(thirdLabel)
        
        ////
        // Fill in the marks
        let builtMarks = self.parseMarks()
        if let best = builtMarks?["best"] {
            updateLabel(bestLabel, withMark: best)
        }
        if let first = builtMarks?["1st"] {
            updateLabel(firstLabel, withMark: first)
        }
        if let second = builtMarks?["2nd"] {
            updateLabel(secondLabel, withMark: second)
        }
        if let third = builtMarks?["3rd"] {
            updateLabel(thirdLabel, withMark: third)
        }
        
        
        ////
        // Constraints
        backgroundView.topAnchor.constraint(equalTo: headerLabel!.bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        athleteLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20).isActive = true
        athleteLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20).isActive = true
        
        bestLabel.topAnchor.constraint(equalTo: athleteLabel.topAnchor).isActive = true
        bestLabel.leadingAnchor.constraint(equalTo: athleteLabel.trailingAnchor, constant: 20).isActive = true
        bestLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20).isActive = true
        
        firstLabel.topAnchor.constraint(equalTo: athleteLabel.bottomAnchor, constant: 8).isActive = true
        firstLabel.leadingAnchor.constraint(equalTo: athleteLabel.leadingAnchor).isActive = true
        firstLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        secondLabel.topAnchor.constraint(equalTo: firstLabel.topAnchor).isActive = true
        secondLabel.leadingAnchor.constraint(equalTo: firstLabel.trailingAnchor, constant: 8).isActive = true
        secondLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        thirdLabel.topAnchor.constraint(equalTo: firstLabel.topAnchor).isActive = true
        thirdLabel.leadingAnchor.constraint(equalTo: secondLabel.trailingAnchor, constant: 8).isActive = true
        thirdLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        scoreInput?.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        scoreInput?.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -20).isActive = true
        scoreInput?.widthAnchor.constraint(equalToConstant: 298).isActive = true
        scoreInput?.heightAnchor.constraint(equalToConstant: 298).isActive = true
        
    }
    
    func updateLabel(_ label: UILabel, withMark: String) {
        let attributedString = NSMutableAttributedString(attributedString: label.attributedText!)
        let originalString = attributedString.string
        attributedString.mutableString.setString(originalString + "\n\(withMark)")
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 16.0), range: NSMakeRange(originalString.count, attributedString.length - originalString.count))
        label.attributedText = attributedString
    }
}



extension HorizontalScoreViewController {
    
    
    /// Convert given marks to a dictionary to use. This converts them to human
    /// readable format.
    /// - Returns: A dictionary that should contain the proper marks if they are
    /// there. Keyed by 1st, 2nd, 3rd, best
    func parseMarks() -> Dictionary<String, String>? {
        
        var returnDictionary: Dictionary<String, String>? = nil
        
        guard let measurementType = eventData?.measurementParams.measurementType else { return returnDictionary }
        
        if let marks = athleteData?.marks {
            if !marks.isEmpty {
                
                var bestMark: Decimal = 0
                returnDictionary = Dictionary()
                
                
                // TODO: Refactor the next three conditionals into a function
                if marks.count > 0 {
                    let firstMark = marks[0]
                    
                    if let mark = firstMark.mark {
                        
                        if measurementType == MeetMeasurementType.Imperial.rawValue {
                            if let totalInches = MeetMeasurementType.convertFormattedString(toInches: mark) {
                                let decimalTotalInches = Decimal(totalInches)
                                returnDictionary?["1st"] = MeetMeasurementType.convertInches(toHumanString: totalInches)
                                if decimalTotalInches > bestMark {
                                    bestMark = decimalTotalInches
                                }
                            }
                        } else {
                            if var totalCM = MeetMeasurementType.convertHumanString(toCentimeters: mark) {
                                totalCM = totalCM * 100
                                returnDictionary?["1st"] = MeetMeasurementType.convertCentimeters(toHumanString: totalCM)
                                if totalCM > bestMark {
                                    bestMark = totalCM
                                }
                            }
                        }
                    }
                }
                
                if marks.count > 1 {
                    let secondMark = marks[1]
                    if let mark = secondMark.mark {
                        
                        if measurementType == MeetMeasurementType.Imperial.rawValue {
                            if let totalInches = MeetMeasurementType.convertFormattedString(toInches: mark) {
                                let decimalTotalInches = Decimal(totalInches)
                                returnDictionary?["2nd"] = MeetMeasurementType.convertInches(toHumanString: totalInches)
                                if decimalTotalInches > bestMark {
                                    bestMark = decimalTotalInches
                                }
                            }
                        } else {
                            if var totalCM = MeetMeasurementType.convertHumanString(toCentimeters: mark) {
                                totalCM = totalCM * 100
                                returnDictionary?["2nd"] = MeetMeasurementType.convertCentimeters(toHumanString: totalCM)
                                if totalCM > bestMark {
                                    bestMark = totalCM
                                }
                            }

                        }
                    }
                }
                
                if marks.count > 2 {
                    let thirdMark = marks[2]
                    if let mark = thirdMark.mark {
                        
                        if measurementType == MeetMeasurementType.Imperial.rawValue {

                            if let totalInches = MeetMeasurementType.convertFormattedString(toInches: mark) {
                                let decimalTotalInches = Decimal(totalInches)
                                returnDictionary?["3rd"] = MeetMeasurementType.convertInches(toHumanString: totalInches)
                                if decimalTotalInches > bestMark {
                                    bestMark = decimalTotalInches
                                }
                            }
                        } else {
                            if var totalCM = MeetMeasurementType.convertHumanString(toCentimeters: mark) {
                                totalCM = totalCM * 100
                                returnDictionary?["3rd"] = MeetMeasurementType.convertCentimeters(toHumanString: totalCM)
                                if totalCM > bestMark {
                                    bestMark = totalCM
                                }
                            }

                        }
                    }
                }
                
                if bestMark > 0 {
                    if measurementType == MeetMeasurementType.Imperial.rawValue {
                        returnDictionary?["best"] = MeetMeasurementType.convertInches(toHumanString: Double(truncating: bestMark as NSNumber))
                    } else {
                        returnDictionary?["best"] = MeetMeasurementType.convertCentimeters(toHumanString: bestMark)
                    }
                }
            }
        }
        
        if let keys = returnDictionary?.keys, keys.count < 1 {
            returnDictionary = nil
        }
        
        return returnDictionary
        
    }
    
    func errorAlert() -> UIAlertController {
        
        let alertController = UIAlertController(title: "Saving Unsuccessful", message: "A connection could not be established with the server. Please check your connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let successAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(successAction)
        
        return alertController
    }
    
    @objc
    func labelTapped(_ sender: UITapGestureRecognizer) {
        
        guard let tag = sender.view?.tag else { return }
        guard let measurement = eventData?.measurementParams.measurementType else { return }
        var valueToGet: String? = nil
        
        // Figure out which tag we're dealing with
        switch tag {
        case 1:
            firstLabel.selected = true
            secondLabel.selected = false
            thirdLabel.selected = false
            
            selectedIndex = 1
            valueToGet = firstLabel.attributedText?.string
        case 2:
            firstLabel.selected = false
            secondLabel.selected = true
            thirdLabel.selected = false
            
            selectedIndex = 2
            valueToGet = secondLabel.attributedText?.string
        case 3:
            firstLabel.selected = false
            secondLabel.selected = false
            thirdLabel.selected = true
            
            selectedIndex = 3
            valueToGet = thirdLabel.attributedText?.string
        default:
            firstLabel.selected = false
            secondLabel.selected = false
            thirdLabel.selected = false
        }
        
        guard var valueToSet = valueToGet else { return }
        
        // Grab the substring from the label to update
        if valueToSet.count > 1 {
            let labels = valueToSet.split(separator: "\n")
            if labels.count > 1 {
                valueToSet = String(labels[1])
            }
        }

        // Get out of here if we don't have a valid label
        if valueToSet.count < 1 {
            return
        }
        
        // Get that value set set set
            // Convert it to the units the scale will understand
        if measurement == MeetMeasurementType.Imperial.rawValue {
            if let valueToEnter = MeetMeasurementType.convertHumanString(toInches: valueToSet) {
                scoreInput?.value = Int(valueToEnter)
            }
        } else {
            if let valueToEnter = MeetMeasurementType.convertHumanString(toCentimeters: valueToSet) {
                scoreInput?.value = (valueToEnter as NSNumber).intValue
            }
        }
    }
    
    func saveMarks() {
        if let viewControllers = navigationController?.viewControllers, let index = viewControllers.index(of: self), let athleteData = athleteData {
            
            if index > 0 {
                let eventAthletsViewController: EventAthletesViewController = viewControllers[index-1] as! EventAthletesViewController
                eventAthletsViewController.updateAthleteData(athleteData)
            }
        }
    }
}

extension HorizontalScoreViewController: FSScoreDialDelegate {
    
    func dialDidUpdateValue(_ dial: FSScoreDial, value: Int) {
        
        // Translate value to american distance
        guard let measurementType = eventData?.measurementParams.measurementType else { return }
        
        if measurementType == MeetMeasurementType.Imperial.rawValue {
            
            dial.displayLabel?.text = MeetMeasurementType.convertInches(toHumanString: Double(value))
        } else {
            dial.displayLabel?.text = MeetMeasurementType.convertCentimeters(toHumanString: Decimal(value))
        }
    }
    
    func dialDidTap(_ dial: FSScoreDial) {
        
        // Don't do anything if we don't have a value to work with.
        if dial.value == 0 {
            return
        }
        
        // Send the marks!!!!!!
        // Figure out which mark to send
        print("SENDIT! \(dial.currentValue)")
        guard let measurementType = eventData?.measurementParams.measurementType else { return }
        
        // If we have a selected index, only update the mark at that index, otherwise
        // add it
        if selectedIndex > 0 && selectedIndex < 4 {
            athleteData?.addMark(dial.currentValue, type: measurementType, index: selectedIndex-1)
            selectedIndex = 0
        } else {
            athleteData?.addMark(dial.currentValue, type: measurementType, index: nil)
        }
        
        self.animateProcess(true)
        if let marks = athleteData?.marks, let eventID = eventData?.eventID, let entryID = athleteData?.entryID, let type = eventData?.measurementParams.measurementType {
            AthleteData.postMarks(marks, eventID: eventID, entryID: entryID, type: type) { [weak self] (error) in
                
                if error != nil {
                    // Show error
                    if let alert = self?.errorAlert() {
                        self?.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                
                // Replace previous vc athletedata with this athletedata??
                self?.saveMarks()
                
                // Stop the animation because we finished
                self?.animateProcess(false)
                
                // Give feedback we actually saved
                let scView = SuccessCheck(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                if var centerPoint = self?.view.center {
                    centerPoint.y = centerPoint.y - 80
                    scView.center = centerPoint
                }
                self?.view.addSubview(scView)
                scView.initWithTime(withDuration: 0.04, bgCcolor: UIColor.fsDarkGray(), colorOfStroke: UIColor.white, widthOfTick: 5) {
                    
                    // Bombout when we are done animating
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func dialShouldRotate(_ dial: FSScoreDial) -> Bool {
        
        var returnValue = true
        if let count = athleteData?.marks?.count {
            if count >= 3 && selectedIndex < 1 {
                returnValue = false
            }
        }
        
        return returnValue
    }
}
