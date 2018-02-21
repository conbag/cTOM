//
//  Result.swift
//  cTOM
//
//  Created by Conor O'Grady on 30/01/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import Foundation


class Result {
    // Object to capture results for each trial
    
    
    private var answerTag: Int
    private var accuracyMeasure: String
    private var trialID: Int
    private var secondMeasure: Double
    private var order: Int
    private var date: String
    private var session: Int
    
    
    init(answerTag: Int, accuracyMeasure: String, trialID: Int, secondMeasure: Double, order: Int, date: String, session: Int) {
        self.answerTag = answerTag
        self.accuracyMeasure = accuracyMeasure
        self.trialID = trialID
        self.secondMeasure = secondMeasure
        self.order = order
        self.date = date
        self.session = session
    }
    
    func getAnswerTag() -> Int {
        return self.answerTag
    }
    
    
    func getAccuracyMeasure() -> String {
        return self.accuracyMeasure
    }
    
    func getTrialID() -> Int {
        return self.trialID
    }
    
    func getSecondMeasure() -> Double {
        return self.secondMeasure
    }
    
    func getOrder() -> Int {
        return self.order
    }
    
    func getDate() -> String {
        return self.date
    }
    
    func getSession() -> Int {
        return self.session
    }
    
}
