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
    
    
    init(answerTag: Int, accuracyMeasure: String, trialID: Int) {
        self.answerTag = answerTag
        self.accuracyMeasure = accuracyMeasure
        self.trialID = trialID
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
    
}
