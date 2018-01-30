//
//  ViewController.swift
//  cTOM
//
//  Created by Conor O'Grady on 29/01/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var ctomDB: FMDatabase = FMDatabase()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Checks to see if .db file exists in documents directory and copies from main bundle if needed
        DBManager.sharedInstance.copyDatabaseIfNeeded()
        
        
        // Opens DB
        ctomDB = DBManager.sharedInstance.openDatabase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

