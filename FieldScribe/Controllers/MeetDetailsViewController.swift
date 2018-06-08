//
//  MeetDetailsViewController.swift
//  FieldScribe
//
//  Created by Cody Garvin on 3/6/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import UIKit

class MeetDetailsViewController: FieldScribeAbstractViewController {
    
    //// Attributes
    @IBOutlet var meetTable: UITableView!

    var meetData: MeetData
    var eventData: Array<EventData>? = nil
    
    init(meetData: MeetData) {
        self.meetData = meetData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        meetData = MeetData(meetID: 0, meetName: "", meetDate: nil, meetLocation: "", measurementType: .Imperial)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        meetTable.dataSource = self
        meetTable.delegate = self
        meetTable.register(AthleteTableViewCell.self, forCellReuseIdentifier: "MeetCell")
        meetTable.register(AthleteTableViewCell.self, forCellReuseIdentifier: "PlaceCell")

        
        title = "Meet Events"

        animateProcess(true)
        
        // Grab the events for the meet
        EventData.fetchEventsForMeet(meetData.meetID) { [weak self] (data) in
            // Store off the athleteData
            self?.eventData = data
            
            self?.animateProcess(false)
            
            // Reload the world
            self?.meetTable.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


////////////////////////////////////////////////////////////////////////////////
// MARK: - UITableViewDataSource & UITableViewDelegate Methods

extension MeetDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            return
        }
        
        // Grab the model at the index path
        guard let eventData = eventData else { return }
        if eventData.count >= indexPath.row {
            let eventModel = eventData[indexPath.row]
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: EventAthletesViewController = storyBoard.instantiateViewController(withIdentifier: "EventAthletes") as! EventAthletesViewController
            viewController.eventData = eventModel;
            navigationController?.pushViewController(viewController, animated: true)
            
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }
}

extension MeetDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return viewForSection(section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let headerLabel = viewForSection(section)
        
        return headerLabel.bounds.size.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            return eventData?.count ?? 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // One for main header, one for actual events
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tableViewCell = AthleteTableViewCell()
        if indexPath.section == 0 {
            tableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! AthleteTableViewCell
        } else {
            tableViewCell = tableView.dequeueReusableCell(withIdentifier: "MeetCell", for: indexPath) as! AthleteTableViewCell
        }
        
        if indexPath.section == 0 {
            tableViewCell.iconImage = UIImage(named: "MapMarker")
            tableViewCell.mainLabel?.text = meetData.meetLocation
        } else {
            let tempData = eventData?[indexPath.row]

            tableViewCell.mainLabel?.text = tempData?.eventName
            
            if let flightNumber = tempData?.flightNumber {
                tableViewCell.rightLabel?.text = "(Flight: \(flightNumber))"
            }
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
        if section == 0 {
            
            var meetDateString = ""
            if let meetDate = meetData.meetDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                meetDateString = dateFormatter.string(from: meetDate)
            }
            
            headerLabel.text = "\(meetData.meetName)\n\(meetDateString)"
        } else {
            headerLabel.text = "Field Events"
        }
        
        headerLabel.sizeToFit()
        
        return headerLabel
    }
}
