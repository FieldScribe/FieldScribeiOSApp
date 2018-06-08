//
//  MeetsViewController.swift
//  FieldScribe
//
//  Created by Cody Garvin on 10/24/17.
//  Copyright © 2017 OIT. All rights reserved.
//

import UIKit

class MeetsViewController: FieldScribeAbstractViewController {

    //// Attributes
    @IBOutlet var meetTable: UITableView!
    var meetData: Array<MeetData>?

    
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
        
        meetTable.dataSource = self
        meetTable.delegate = self
        meetTable.register(AthleteTableViewCell.self, forCellReuseIdentifier: "MeetCell")
        
        // Fetch meets!
        self.animateProcess(true)
        MeetData.fetchMeets { [weak self] (data)  in
            // Store off the athleteData
            self?.meetData = data
            self?.animateProcess(false)
            // Reload the world
            self?.meetTable.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        meetData = nil
    }


}

////////////////////////////////////////////////////////////////////////////////
// MARK: - UITableViewDataSource && UITableViewDelegate Methods
extension MeetsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell = meetTable.dequeueReusableCell(withIdentifier: "MeetCell", for: indexPath) as! AthleteTableViewCell
        if let tempData = meetData?[indexPath.row] {
            
            var mainColor = UIColor.fsMediumGreen()
            var secondColor = UIColor.fsLightForeground()
            var meetTitle = tempData.meetName
            var activeString = "closed"
            if let meetDate = tempData.meetDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.medium
                meetTitle = meetTitle + "\n\(dateFormatter.string(from: meetDate))"
                dateFormatter.dateStyle = DateFormatter.Style.none
                dateFormatter.timeStyle = DateFormatter.Style.medium
                meetTitle = meetTitle + "\n\(dateFormatter.string(from: meetDate))"
                
                if meetDate.compare(Date.init(timeIntervalSinceNow: 0)) == ComparisonResult.orderedAscending {
                    mainColor = UIColor.fsLightGray()
                    secondColor = UIColor.fsMediumGray()
                } else {
                    activeString = "active"
                }
            }
            
            
            let meetAttributedString = NSMutableAttributedString(string: meetTitle, attributes: [NSAttributedStringKey.foregroundColor: mainColor, .font: UIFont.systemFont(ofSize: 16.0)])
            
            meetAttributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.bold), range: NSMakeRange(0, tempData.meetName.count))
            
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.lineSpacing = 16
//            meetAttributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, meetTitle.count))
//            meetAttributedString.addAttribute(.font, value: [UIFont.systemFont(ofSize: 16.0)], range: NSMakeRange(tempData.meetName.count, meetTitle.count - tempData.meetName.count))

            tableViewCell.mainLabel?.attributedText = meetAttributedString
            tableViewCell.rightLabel?.attributedText = NSAttributedString(string: activeString, attributes: [NSAttributedStringKey.foregroundColor: secondColor])
        }
        
        return tableViewCell
    }
}

extension MeetsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Grab the model at the index path
        guard let meetData = meetData else { return }
        if meetData.count >= indexPath.row {
            let meetModel = meetData[indexPath.row]
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: MeetDetailsViewController = storyBoard.instantiateViewController(withIdentifier: "MeetDetails") as! MeetDetailsViewController
            viewController.meetData = meetModel
            navigationController?.pushViewController(viewController, animated: true)
            
        }
    }
}

