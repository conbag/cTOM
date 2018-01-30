//
//  DBManager.swift
//  cTOM
//
//  Created by Conor O'Grady on 29/01/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import Foundation


class DBManager {
    
    static let sharedInstance = DBManager()
    
    let dbFileName: String = "cTOM.db"
    var ctomDB: FMDatabase!
    
    
    func copyDatabaseIfNeeded() {
        // Move database file from bundle to documents folder
        
        let fileManager = FileManager.default
        
        let documentsUrl = fileManager.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            return // Could not find documents URL
        }
        
        let finalDatabaseURL = documentsUrl.first!.appendingPathComponent(dbFileName)
        
        if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false) {
            print("DB does not exist in documents folder")
            
            let documentsURL = Bundle.main.resourceURL?.appendingPathComponent(dbFileName)
            
            do {
                try fileManager.copyItem(atPath: (documentsURL?.path)!, toPath: finalDatabaseURL.path)
            } catch let error as NSError {
                print("Couldn't copy file to final location! Error:\(error.description)")
            }
            
        } else {
            print("Database file found at path: \(finalDatabaseURL.path)")
        }
        
    }
    
    
    func getMediaForTest(test: Int) {
        
        if Trackers.sharedInstance.currentTest == test {
            
            let query = "select * from Trial where test_id = \(test)"
            
            let results:FMResultSet? = ctomDB.executeQuery(query, withArgumentsIn: [])
            
            while results?.next() == true {
                Trackers.sharedInstance.trialList.append((results?.string(forColumn: "trial_name"))!)
            }
            
            
            
            
        }
        
    }
    
    
    func openDatabase() -> FMDatabase {
        
        let fileManager = FileManager.default
        let dirPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        // get directory path for apps documents directory
        
        let dbPath = dirPath[0].appendingPathComponent(dbFileName).path
        // retrieve path of .db file
        
        ctomDB = FMDatabase(path: dbPath as String)
        // create DB
        
        ctomDB.open()
        
        return ctomDB
        
    }
    
    
}
