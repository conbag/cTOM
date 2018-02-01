//
//  Trackers.swift
//  cTOM
//
//  Created by Conor O'Grady on 29/01/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import Foundation

final class Trackers {
    
    // Singleton class to keep track of below variables
    
    static let sharedInstance = Trackers()
    
    static var currentParticipant: Int?
    static var currentTest: Int?
    static var currentSession: Int?
    static var currentTrial: Int?
    static var resultsArray = [Result]()
    // used to store array of results as user proceeds through trials
    
    private init() {}
    
}
