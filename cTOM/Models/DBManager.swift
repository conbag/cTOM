//
//  DBManager.swift
//  cTOM
//
//  Created by Conor O'Grady on 29/01/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import Foundation


final class DBManager {
    
    static let sharedInstance = DBManager()
    
    static let dbFileName: String = "cTOM.db"
    static var ctomDB: FMDatabase!
    static var trialList = [Int]()
    static var trialWithVideo = [Int : String]()
    static var trialWithAnswer = [Int : Int]()
    // dictionary to story correct answers with id's
    
    private init() {}
    
    
    static func getTrialInfoForTest(test: Int) {
        if Trackers.currentTest == test {
            
            let query = "select * from Trial where test_id = \(test)"
            // will need to change this to join for stories trials
            
            let results:FMResultSet? = DBManager.ctomDB.executeQuery(query, withArgumentsIn: [])
            
            while results?.next() == true {
                trialList.append(Int((results?.int(forColumn: "trial_id"))!))
                trialWithVideo[Int((results?.int(forColumn: "trial_id"))!)] = (results?.string(forColumn: "trial_name"))!
                trialWithAnswer[Int((results?.int(forColumn: "trial_id"))!)] = Int((results?.int(forColumn: "correct_answer_tag"))!)
            }
        }
    }
    // extracts video paths for specific test and stors in array. Also store trial id and correct answers in dictionary
    
    
    static func storeResultsToDatabase() {
        
        let update = "INSERT INTO `Trial-Session`(`trial_id`, `answer_tag`, `accuracy_measure`, 'time_measure', 'trial_order') VALUES (?, ?, ?, ?, ?);"
        
        for result in Trackers.resultsArray {
            
            do {
                try DBManager.ctomDB.executeUpdate(update, values: [result.getTrialID(), result.getAnswerTag(), result.getAccuracyMeasure(), result.getSecondMeasure(), result.getOrder()])
            } catch {
                print(error)
            }
        }
    }
    // Store various data from various result objects to DB
    
    
    static func copyDatabaseIfNeeded() {
        // Move database file from bundle to documents folder
        
        let fileManager = FileManager.default
        
        let documentsUrl = fileManager.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            return // Could not find documents URL
        }
        
        let finalDatabaseURL = documentsUrl.first!.appendingPathComponent(DBManager.dbFileName)
        
        if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false) {
            print("DB does not exist in documents folder")
            
            let documentsURL = Bundle.main.resourceURL?.appendingPathComponent(DBManager.dbFileName)
            
            do {
                try fileManager.copyItem(atPath: (documentsURL?.path)!, toPath: finalDatabaseURL.path)
            } catch let error as NSError {
                print("Couldn't copy file to final location! Error:\(error.description)")
            }
            
        } else {
            print("Database file found at path: \(finalDatabaseURL.path)")
        }
        
    }
    
    static func openDatabase() {
        
        let fileManager = FileManager.default
        let dirPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        // get directory path for apps documents directory
        
        let dbPath = dirPath[0].appendingPathComponent(DBManager.dbFileName).path
        // retrieve path of .db file
        
        DBManager.ctomDB = FMDatabase(path: dbPath as String)
        // create DB
        
        DBManager.ctomDB.open()

        
    }
    
    
}
