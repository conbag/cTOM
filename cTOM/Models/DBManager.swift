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
    
    private init() {}
    
    
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
