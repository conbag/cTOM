//
//  ViewController.swift
//  cTOM
//
//  Created by Conor O'Grady on 29/01/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit

class ViewControllerTests: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DBManager.createNewSession()
        // creates new session for 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

