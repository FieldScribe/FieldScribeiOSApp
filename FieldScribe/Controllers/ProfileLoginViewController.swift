//
//  ProfileLoginViewController.swift
//  FieldScribe
//
//  Created by Cody Garvin on 5/15/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import UIKit

class ProfileLoginViewController: FieldScribeAbstractViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let leftButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC(_:)))
        self.navigationItem.leftBarButtonItem = leftButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func dismissVC(_ sender: UIView) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
