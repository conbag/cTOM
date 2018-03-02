//
//  ResultSummary.swift
//  cTOM
//
//  Created by Conor O'Grady on 02/03/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import Foundation

class ResultSummary {
    // Object to capture results data for summary section
    
    private var accuracyMeasure: String
    private var sessionID: Int
    private var meanReaction: String
    private var participantID: String
    private var date: String
    
    init(accuracyMeasure: String, sessionID: Int, meanReaction: String, participantID: String, date: String) {
        self.accuracyMeasure = accuracyMeasure
        self.sessionID = sessionID
        self.meanReaction = meanReaction
        self.participantID = participantID
        self.date = date
    }
    
    func getAccuracyMeasure() -> String {
        return self.accuracyMeasure
    }
    
    func getSessionID() -> Int {
        return self.sessionID
    }
    
    func getMeanReaction() -> String {
        return self.meanReaction
    }
    
    func getParticipantID() -> String {
        return self.participantID
    }
    
    func getDate() -> String {
        return self.date
    }
    
}
