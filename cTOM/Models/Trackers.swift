//
//  Trackers.swift
//  cTOM
//
//  Created by Conor O'Grady on 29/01/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import Foundation


struct Trackers {
    
    static var sharedInstance = Trackers()
    
    var currentParticipant: Int?
    var currentTest: Int?
    var trialList = [String] ()
    var currentTrial: Int?
    
    
}
