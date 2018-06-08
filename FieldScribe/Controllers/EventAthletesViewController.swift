//
//  EventAthletesViewController.swift
//  FieldScribe
//
//  Created by Cody Garvin on 3/10/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import UIKit

class EventAthletesViewController: FieldScribeAbstractViewController {
    
    //// Attributes
    @IBOutlet var athleteTable: UITableView!

    var eventData: EventData? = nil
    var athleteData: Array<AthleteData>? = nil
    
    init(eventData: EventData) {
        self.eventData = eventData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        athleteTable.dataSource = self
        athleteTable.delegate = self
        athleteTable.register(AthleteTableViewCell.self, forCellReuseIdentifier: "MeetCell")
        
        if let eventData = eventData {
            title = eventData.eventName
        } else {
            title = "Event Details"
        }
        
        animateProcess(true)
        
        // Grab the athletes for the event
        guard let eventID = eventData?.eventID else { return }
        AthleteData.fetchAthletesForEvent(eventID) { [weak self] (data) in
            // Store off the athleteData
            
            var tempArray = Array<AthleteData>()
            for var tempData in data {
                tempData.normalizeBestMark()
                tempArray.append(tempData)
            }
            
            self?.athleteData = tempArray
            
            self?.animateProcess(false)
            
            // Reload the world
            self?.athleteTable.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        athleteTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Update particular data with updated data
    ///
    /// - Parameter updatedData: The data that will replace existing data
    func updateAthleteData(_ updatedData: AthleteData) {
        
        guard let tempAthleteData = athleteData else { return }
        
        // Loop through to find the correct index
        if let index = tempAthleteData.index(where: { $0.eventID == updatedData.eventID && $0.entryID == updatedData.entryID }) {
            // update the data at index
            athleteData?[index] = updatedData
        }
    }
}

extension EventAthletesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Grab the data
        guard let athleteData = athleteData else { return }
        
        if athleteData.count > indexPath.row {
            
            let athlete = athleteData[indexPath.row]
            
            if let eventType = eventData?.measurementParams.eventType {
                
                if eventType == EventData.EventType.Vertical.rawValue {
                    
                    let viewController: VerticalScoreViewController = VerticalScoreViewController(nibName: nil, bundle: nil)
                    viewController.athleteData = athlete;
                    viewController.eventData = eventData;
                    navigationController?.pushViewController(viewController, animated: true)
                    
                } else if eventType.jsonValue as? String == EventData.EventType.Horizontal.rawValue {
                    
                    let viewController: HorizontalScoreViewController = HorizontalScoreViewController(nibName: nil, bundle: nil)
                    viewController.athleteData = athlete
                    viewController.eventData = eventData
                    navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }
    }
}

extension EventAthletesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return viewForSection(section)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let headerLabel = viewForSection(section)
        
        return headerLabel.bounds.size.height
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return athleteData?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "MeetCell", for: indexPath) as! AthleteTableViewCell
        let tempData = athleteData?[indexPath.row]
        
        guard let athleteName = tempData?.properName()
            else { return tableViewCell }
        
        let mainColor = UIColor.fsMediumGreen()
        let secondColor = UIColor.fsLightForeground()
        
        if let competitionNumber = tempData?.competitionNumber, let teamName = tempData?.teamName {
            
            // If we have a best score add it
            let rightString = "Number: \(competitionNumber)"
            var bestString: String? = nil
            var finalString = NSMutableAttributedString(string: rightString, attributes: [NSAttributedStringKey.foregroundColor: secondColor, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            if let bestScore = tempData?.bestMark {
                bestString = "Best: \(bestScore)"
                let tempString = rightString + "\n" + bestString!
                finalString = NSMutableAttributedString(string: tempString, attributes: [NSAttributedStringKey.foregroundColor: secondColor, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
                finalString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(rightString.count, bestString!.count))
            }
            tableViewCell.rightLabel?.attributedText = finalString
            
            
            let finalAthleteTitle = athleteName + "\n\(teamName)"
            let meetAttributedString = NSMutableAttributedString(string: finalAthleteTitle, attributes: [NSAttributedStringKey.foregroundColor: mainColor, .font: UIFont.systemFont(ofSize: 16.0)])

            meetAttributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.bold), range: NSMakeRange(0, athleteName.count))
            
            tableViewCell.mainLabel?.attributedText = meetAttributedString
        }
        
        return tableViewCell
    }
    
    
    func viewForSection(_ section: Int) -> UIView {
        
        let headerLabel = FSLabel()
        
        headerLabel.numberOfLines = 0
        headerLabel.font = UIFont.boldSystemFont(ofSize: 28.0)
        headerLabel.textColor = UIColor.fsLightForeground()
        headerLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        headerLabel.backgroundColor = UIColor.fsDarkBackground()
        
        var fieldString = "Field Events"
        if let flightNumber = eventData?.flightNumber {
            fieldString = "Flight \(flightNumber)"
        }
        
        if var subName = eventData?.eventSubName, !subName.isEmpty {
            subName = subName + "\n\(fieldString)"
            headerLabel.text = subName
        } else {
            headerLabel.text = fieldString
        }
        
        headerLabel.sizeToFit()
        
        return headerLabel
    }

}
