//
//  cTOMTests.swift
//  cTOMTests
//
//  Created by Conor O'Grady on 29/01/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import XCTest
@testable import cTOM

class cTOMTests: XCTestCase {
    
    var result: Result?

    override func setUp() {
        super.setUp()
        
        result = Result(answerTag: "4", accuracyMeasure: "TRUE", trialID: 20, secondMeasure: 3.214, order: 2, date: "2018-03-21 17:05:02", session: 3)
        // creating new instance of Result object on setup
    }
    
    func testResultGetters() {
        
        XCTAssertEqual(result?.getAnswerTag(), "4")
        XCTAssertEqual(result?.getAccuracyMeasure(), "TRUE")
        XCTAssertEqual(result?.getTrialID(), 20)
        XCTAssertEqual(result?.getSecondMeasure(), 3.214)
        XCTAssertEqual(result?.getOrder(), 2)
        XCTAssertEqual(result?.getDate(), "2018-03-21 17:05:02")
        XCTAssertEqual(result?.getSession(), 3)
    }
    // ensure that all getter functions in Result class are correct

}
