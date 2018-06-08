//
//  FieldScribeAbstractViewController.swift
//  FieldScribe
//
//  Created by Cody Garvin on 4/24/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import UIKit

class FieldScribeAbstractViewController: UIViewController {
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var hideProfile: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titleImageView = UIImageView(image: UIImage(named: "FieldScribeLogo"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        titleImageView.contentMode = UIViewContentMode.scaleAspectFit
        self.navigationItem.titleView = titleImageView
        
        view.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        var centerPoint = view.center
        centerPoint.y = centerPoint.y - 80
        activityIndicator.center = centerPoint
        
        let backButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButtonItem


        // Add our Profile
        if (!hideProfile) {
            let rightButton = UIBarButtonItem(image: UIImage(named: "ProfileIcon"), style: .done, target: self, action: #selector(loginToTheSystem(_:)))
            self.navigationItem.rightBarButtonItem = rightButton
        }
    }
    
    func animateProcess(_ animate: Bool) {
        if animate {
            view.bringSubview(toFront: activityIndicator)
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func loginToTheSystem(_ sender: UIButton) {
        // Present the login view controller
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: ProfileLoginViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileLogin") as! ProfileLoginViewController
        viewController.hideProfile = true
        self.present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
    }

}
