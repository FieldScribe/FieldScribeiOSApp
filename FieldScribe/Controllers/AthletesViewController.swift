//
//  AthletesViewController.swift
//  FieldScribe
//
//  Created by Cody Garvin on 10/24/17.
//  Copyright © 2017 OIT. All rights reserved.
//

import UIKit

class AthletesViewController: UIViewController {
    
    //// Attributes
    @IBOutlet var athleteTable: UITableView!
    var athleteData: Array<AthleteData>?
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Initializers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        athleteTable.dataSource = self
        athleteTable.register(AthleteTableViewCell.self, forCellReuseIdentifier: "AthleteCell")
        
        // Fetch an athlete!
        AthleteData.fetchAthletes { (data) in
            // Store off the athleteData
            self.athleteData = data
            
            // Reload the world
            self.athleteTable.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        athleteData = nil
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Private Methods
}

////////////////////////////////////////////////////////////////////////////////
// MARK: - UITableViewDataSource && UITableViewDelegate Methods
extension AthletesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return athleteData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = athleteTable.dequeueReusableCell(withIdentifier: "AthleteCell", for: indexPath)        
        let tempData = athleteData?[indexPath.row]
        
        tableViewCell.textLabel?.text = tempData?.fullName()
        tableViewCell.detailTextLabel?.text = tempData?.teamName
        
        return tableViewCell
    }
}

