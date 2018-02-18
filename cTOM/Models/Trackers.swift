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
    
    static var adminLoggedIn = false
    static var currentAdminEmail: String?
    static var currentAdmin: Int?
    // keeps track of currently logged in admin_id
    
    static var currentParticipant: Int?
    static var currentTest: Int?
    static var currentSession: Int?
    static var currentTrial: Int?
    static var randomizedTrialList = [Int]()
    // randomized trial list for sequence of videos
    static var resultsArray = [Result]()
    // used to store array of results as user proceeds through trials
    
    private init() {}
    
    
    static func randomizeArray(array : [Int]) {
        var randomizedArray : [Int] = []
        var copyOfArray = array
        while !copyOfArray.isEmpty {
            let arrayCount = copyOfArray.count
            let randomElement = Int(arc4random_uniform(UInt32(arrayCount)))
            let arraySlice = copyOfArray[randomElement]
            randomizedArray.append(arraySlice)
            copyOfArray.remove(at : randomElement)
        }
        
        randomizedTrialList = randomizedArray
    }
    
//    function to randomize trial list taken from database
//
//    works by creating empty array and copy of passed in array.
//    takes random index element at random index of copied array and passes to empty array.
//    removes the passed element from copied array and repeats above steps until copied array is empty.
 
    
}
