//
//  HorizontalScoreViewController.swift
//  FieldScribe
//
//  Created by Cody Garvin on 3/12/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import UIKit

let labelReuseIdentifier = "ScoreCell";
let headerReuseIdentifier = "HeightCell";

class VerticalScoreViewController: FieldScribeAbstractViewController {

    ////
    // MARK: - Properties
    var eventData: EventData? = nil
    var athleteData: AthleteData? = nil
    var headerLabel: FSLabel? = nil
    var firstLabel: FSLabel!
    var secondLabel: FSLabel!
    var thirdLabel: FSLabel!

    var scoreCollectionView: UICollectionView! = nil
    var barHeights: Array<BarHeightData>?
    
    private var selectedIndex: NSInteger = 0
    private var selectedBarHeight: BarHeightData? = nil
    
    ////
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure our eventData.barHeights are clean and in order
        eventData?.sortBarHeights()

        guard let eventData = eventData else { return }
        
        title = "\(eventData.eventName)"
        
        /// Add the measurements
        let increment = Decimal(eventData.measurementParams.precision)
        let maximum = eventData.measurementParams.measurementType == MeetMeasurementType.Imperial.rawValue ? Decimal(eventData.measurementParams.maximum * 12) : Decimal(eventData.measurementParams.maximum)
        var measurement = eventData.measurementParams.measurementType == MeetMeasurementType.Imperial.rawValue ? Decimal(1) : Decimal(1)
        var count = 1
        barHeights = Array<BarHeightData>()
        while measurement <= maximum {
            
            if eventData.measurementParams.measurementType == MeetMeasurementType.Imperial.rawValue {
                
                let feet = NSDecimalNumber(decimal: measurement).intValue
                let previousIncrement = measurement - Decimal(feet)
                let measurements = MeetMeasurementType.convertInches(toFeetAndInches: Double(truncating: measurement as NSNumber))
                let barHeight = BarHeightData(heightNumber: count, attemptNumber: count, feet: measurements.feet, inches: measurements.inches, meters: nil)
                barHeights?.append(barHeight)

                measurement = Decimal(feet) + (previousIncrement + increment)
                
            } else if eventData.measurementParams.measurementType == MeetMeasurementType.Metric.rawValue {
                
                let barHeight = BarHeightData(heightNumber: count, attemptNumber: count, feet: nil, inches: nil, meters: measurement)
                barHeights?.append(barHeight)

                measurement = measurement + increment
            }
            
            count += 1
        }
        
        // Make sure our athleteData.verticalMarks are clean
        cleanVerticalMarks()
        
        // Make sure we have the actual marks matching markstring
        athleteData?.cleanupVerticalMarks()
        
        /// Add views
        buildViews()
        
        scoreCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension VerticalScoreViewController {
    
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
        
        // Score Collection View
        let layout = StepCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: 75, height: 80)
        scoreCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        scoreCollectionView.backgroundColor = UIColor.fsDarkGray()
        scoreCollectionView.showsHorizontalScrollIndicator = false
        scoreCollectionView.register(HeightCollectionViewCell.self, forCellWithReuseIdentifier: headerReuseIdentifier)
        scoreCollectionView.dataSource = self
        scoreCollectionView.delegate = self
        scoreCollectionView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(scoreCollectionView)
        
        let successButton = UIButton(frame: .zero)
        successButton.addTarget(self, action: #selector(scoreButtonTapped(_:)), for: .touchUpInside)
        successButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 112)
        successButton.setTitleColor(UIColor.fsMediumGreen(), for: .normal)
        successButton.setTitle("O", for: .normal)
        let failButton = UIButton(frame: .zero)
        failButton.addTarget(self, action: #selector(scoreButtonTapped(_:)), for: .touchUpInside)
        failButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 112)
        failButton.setTitleColor(UIColor.fsLightGray(), for: .normal)
        failButton.setTitle("X", for: .normal)
        let passButton = UIButton(frame: .zero)
        passButton.addTarget(self, action: #selector(scoreButtonTapped(_:)), for: .touchUpInside)
        passButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 112)
        passButton.setTitleColor(UIColor.fsMediumGray(), for: .normal)
        passButton.setTitle("P", for: .normal)
        let stackView = UIStackView(arrangedSubviews: [successButton, failButton, passButton])
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stackView)
        
        ////
        // Fill in the marks
        if let builtMarks = self.parseMarks(), let measurementType = eventData?.measurementParams.measurementType {
            if builtMarks.count > 0  {
                let best = builtMarks[0]
                
                if measurementType == MeetMeasurementType.Imperial.rawValue {
                    if let feet = best.feet, let inches = best.inches {
                        let totalInches = MeetMeasurementType.convertToInchesWithFeet(feet, inches: inches)
                        updateLabel(bestLabel, withLetter: MeetMeasurementType.convertInches(toHumanString: totalInches))
                    }
                } else {
                    if let meters = best.meters {
                        updateLabel(bestLabel, withLetter: MeetMeasurementType.convertCentimeters(toMetersHumanString: meters*100), marker: "\n")
                    }
                }
                updateLabelsForMarkString(best.marksString)
            }
        }
        
        ////
        // Build constraints
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
        
        scoreCollectionView.topAnchor.constraint(equalTo: firstLabel.bottomAnchor, constant: 10).isActive = true
        scoreCollectionView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10).isActive = true
        scoreCollectionView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10).isActive = true
        scoreCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        stackView.topAnchor.constraint(equalTo: scoreCollectionView.bottomAnchor, constant: 10).isActive = true
        stackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10).isActive = true
    }
}

////////////////////////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDelegate Methods
extension VerticalScoreViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}

////////////////////////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDataSource Methods
extension VerticalScoreViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return barHeights?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! HeightCollectionViewCell
        
        if indexPath.row < (barHeights?.count ?? 0) {
            if let barHeight = barHeights?[indexPath.row] {
                cell.mainLabel.text = barHeight.prettyStringRepresentation()
            }
        }

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // workaround to center to every cell including ones near margins
        if let cell = collectionView.cellForItem(at: indexPath) {
            let offset = CGPoint(x: cell.center.x - collectionView.frame.width / 2, y: 0)
            collectionView.setContentOffset(offset, animated: true)
        }
        
        // Grab the current bar height
        selectedBarHeight = barHeights?[indexPath.row]
        
        // Clear out the labels before we update them since we are switching
        updateLabelsForMarkString("")
        
        // Grab the mark string to update the labels
        if let athleteHeights = athleteData?.verticalMarks, let selectedBarHeight = selectedBarHeight {
            for tempHeight in athleteHeights {
                if selectedBarHeight == tempHeight {
                    updateLabelsForMarkString(tempHeight.marksString)
                    break
                }
            }
        }
        
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

////////////////////////////////////////////////////////////////////////////////
// MARK: - Private Methods
extension VerticalScoreViewController {
    
    @objc
    func labelTapped(_ sender: UITapGestureRecognizer) {
        
        guard let tag = sender.view?.tag else { return }
        guard let _ = eventData?.measurementParams.measurementType else { return }
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
//        if measurement == MeetMeasurementType.Imperial.rawValue {
//            if let valueToEnter = MeetMeasurementType.convertHumanString(toInches: valueToSet) {
//                scoreInput?.value = Int(valueToEnter)
//            }
//        } else {
//            if let valueToEnter = MeetMeasurementType.convertHumanString(toCentimeters: valueToSet) {
//                scoreInput?.value = Int(valueToEnter)
//            }
//        }
        print("TODO: Add ability to reset to proper score")
    }
    
    @objc
    func scoreButtonTapped(_ sender: UIButton) {
        
        if let letter = sender.title(for: .normal), let selectedBarHeight = selectedBarHeight, let measurementTypeString = eventData?.measurementParams.measurementType {
            
            if let markType = BarHeightMark(rawValue: letter), let entryID = athleteData?.entryID {
                if let type = MeetMeasurementType(rawValue: measurementTypeString), let units = selectedBarHeight.measurementFromUnits() {
                    if let index = athleteData?.addVerticalMark(units, markType: markType, measurementType: type, index: nil) {
                        
                        // Make sure the mark is in the eventData
                        syncEventDataBarHeightsWithAthleteHeights()
                        
                        // Now make sure our bar heights have the correct heightNum by iterating
                        verifyEventDataBarHeightOrder()
                        
                        guard let eventData = eventData else { return }
                        guard let barHeights = eventData.barHeights else { return }
                        guard let barMarks = athleteData?.verticalMarks else { return }
                        print("Updated marks: \(barHeights)")
                        
                        // Show it upstairs!!
                        if index < 3 {
                            updateLabelsForMarkString(barMarks[index].marksString)
                        }
                        
                        // Send off the bar heights
                        BarHeightData.postBarHeights(eventData) { [weak self] (error) in
                            
                            if error == nil {
                                // Send off the new mark
                                print("Succeeded pushing bar heights")
                                AthleteData.postBarHeightMarks(barMarks, eventID: eventData.eventID, entryID: entryID, completion: { (athleteError) in
                                    // Sent marks
                                    if athleteError == nil {
                                        print("Success on athlete marks")
                                        
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

                                    } else {
                                        print("Failed to send the athlete marks")
                                        if let alert = self?.errorAlert() {
                                            self?.present(alert, animated: true, completion: nil)
                                        }
                                    }
                                })
                            } else {
                                print("An error occurred")
                                if let alert = self?.errorAlert() {
                                    self?.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func syncEventDataBarHeightsWithAthleteHeights() {
        
        guard let verticalMarks = athleteData?.verticalMarks else { return }
        
        for athleteMark in verticalMarks {
            
            var indexToInsertAt = 0
            if var eventDataBarHeights = eventData?.barHeights {
                // Loop through the eventDataBarHeights to find if our athleteMark is found
                var found = false
                for (eventIndex, eventMark) in eventDataBarHeights.enumerated() {
                    if eventMark == athleteMark {
                        // FOUND!!! DO NOTHING
                        found = true
                        break
                    } else if eventMark < athleteMark {
                        indexToInsertAt = eventIndex + 1
                    }
                }
                
                // It wasn't found, need to add it in the right spot
                if !found {
                    eventDataBarHeights.insert(athleteMark, at: indexToInsertAt)
                    eventData?.barHeights = eventDataBarHeights
                }
                
            } else {
                // Add our newest mark
                let createdBarHeights = [athleteMark]
                eventData?.barHeights = createdBarHeights
            }
        }
    }
    
    func verifyEventDataBarHeightOrder() {
        
        if var tempEventDataBarHeights = eventData?.barHeights {
            
            for (index, barHeight) in tempEventDataBarHeights.enumerated() {
                var tempBarHeight = barHeight
                tempBarHeight.attemptNumber = index+1
                tempBarHeight.heightNumber = index+1
                tempEventDataBarHeights[index] = tempBarHeight
            }
            
            eventData?.barHeights = tempEventDataBarHeights
        }
    }
    
    func saveMarks() {
        if let viewControllers = navigationController?.viewControllers,
            let index = viewControllers.index(of: self), let athleteData = athleteData {
            
            if index > 0 {
                let eventAthletsViewController: EventAthletesViewController = viewControllers[index-1] as! EventAthletesViewController
                eventAthletsViewController.updateAthleteData(athleteData)
                eventAthletsViewController.eventData = eventData
            }
        }
    }
    
    func parseMarks() -> Array<BarHeightData>? {
        
        var returnArray: Array<BarHeightData>? = nil
        
        guard let barHeights = eventData?.barHeights else { return returnArray }
        
        if let marks = athleteData?.verticalMarks {
            if !marks.isEmpty {
                
                returnArray = Array()
                
                // Find the best mark by taking the current marks and finding the
                // biggest success mark.
                // Do this by iterating the marks backwards since they should be
                // ordered, then check the mark string contains an 'O'. Then
                // match up the mark attemptNumber with the heightNumber that
                // was passed in.
                
                for mainMark in marks.reversed() {
                    if mainMark.marksString.contains(BarHeightMark.Success.rawValue) {
                        
                        // Find the bar height
                        for barHeight in barHeights {
                            
                            if mainMark.attemptNumber == barHeight.heightNumber {
                                // Found our match!
                                print("Found our existing bar height")
                                
                                // Check out best first, if it's blank move on
                                if returnArray!.count < 1 {
                                    var tempBarHeight = barHeight
                                    tempBarHeight.marksString = mainMark.marksString
                                    returnArray?.insert(tempBarHeight, at: 0)
                                }
                                
                                var tempBarHeight = barHeight
                                tempBarHeight.marksString = mainMark.marksString
                                returnArray?.insert(tempBarHeight, at: 1)
                            }
                        }
                    }
                }
            }
        }
        
        if returnArray != nil && returnArray!.isEmpty {
            returnArray = nil
        }
        
        return returnArray
        
    }
    
    func errorAlert() -> UIAlertController {
        
        let alertController = UIAlertController(title: "Saving Unsuccessful", message: "A connection could not be established with the server. Please check your connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let successAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(successAction)
        
        return alertController
    }
    
    func updateLabel(_ label: UILabel, withLetter: String, marker: Character = " ") {
        let attributedString = NSMutableAttributedString(attributedString: label.attributedText!)
        var originalString = attributedString.string
        if originalString.contains(marker) {
            
            if withLetter == "" {
                let split = originalString.split(separator: marker)
                originalString = String(split[0])
                attributedString.mutableString.setString(originalString)
            } else {
                attributedString.mutableString.setString(originalString + "\(withLetter)")
            }
        } else {
            attributedString.mutableString.setString(originalString + "\(marker)\(withLetter)")
        }
        attributedString.addAttribute(NSAttributedStringKey.font,
                                      value: UIFont.boldSystemFont(ofSize: 16.0),
                                      range: NSMakeRange(originalString.count,
                                                         attributedString.length - originalString.count))
        label.attributedText = attributedString
    }
    
    func updateLabelsForMarkString(_ marksString:String) {
        
        // First clear out the labels
        updateLabel(firstLabel, withLetter: "")
        updateLabel(secondLabel, withLetter: "")
        updateLabel(thirdLabel, withLetter: "")
        
        for (index, char) in marksString.enumerated() {
            if index == 0 {
                updateLabel(firstLabel, withLetter: String(char))
            } else if index == 1 {
                updateLabel(secondLabel, withLetter: String(char))
            } else if index == 2 {
                updateLabel(thirdLabel, withLetter: String(char))
            }
        }
    }
    
    
    /// Makes sure that if we get a string of marks from the server they are
    /// converted to full blown marks with actual heightNum and heigh values.
    func cleanVerticalMarks() {
        guard let tempAthleteVerticalData = athleteData?.verticalMarks else { return }
        guard let tempEventVerticalData = eventData?.barHeights else { return }
        guard let measurementType = eventData?.measurementParams.measurementType else { return }
        
        var verticalMarks = Array<BarHeightData>()
        for athleteMark in tempAthleteVerticalData {
            if athleteMark.feet == nil && athleteMark.inches == nil && athleteMark.meters == nil {
                // We found one that needs to be cleaned up
                
                for eventMark in tempEventVerticalData {
                    if eventMark.heightNumber == athleteMark.attemptNumber {
                        var tempAthleteMark = athleteMark
                        
                        if measurementType == MeetMeasurementType.Imperial.rawValue {
                            tempAthleteMark.feet = eventMark.feet
                            tempAthleteMark.inches = eventMark.inches
                        } else {
                            tempAthleteMark.meters = eventMark.meters
                        }
                        tempAthleteMark.heightNumber = eventMark.heightNumber
                        verticalMarks.append(tempAthleteMark)
                        break
                    }
                }
            }
        }
        
        if verticalMarks.count > 0 {
            athleteData?.verticalMarks = verticalMarks
        }
    }
}

