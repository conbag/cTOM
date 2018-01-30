//
//  ViewControllerGaze.swift
//  cTOM
//
//  Created by Conor O'Grady on 30/01/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit
import AVFoundation

class ViewControllerGaze: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    var activeTrial = true
    
    @IBAction func vidAct(_ sender: Any) {

        MediaManager.playTestVideo(videoView: videoView)
        
    }
    // button to begin trials
    
    
    @IBAction func testButton(_ sender: Any) {
        
        DBManager.storeResultsToDatabase()
        
    }
    // Tester button to push results to DB -> will need to be deleted
    
    @IBAction func gazeButton(_ sender: UIButton) {
        
        let currentTrial = Trackers.sharedInstance.currentTrial!
        let correctAnswer = DBManager.trialWithAnswer[currentTrial]
        
        if activeTrial == false {
            sender.isEnabled = false
        }
        
        let result: Result
        
        if sender.tag as Int == correctAnswer {
            result = Result(answerTag: sender.tag, accuracyMeasure: "Correct", trialID: currentTrial)
        } else {
            result = Result(answerTag: sender.tag, accuracyMeasure: "Incorrect", trialID: currentTrial)
        }
        
        Trackers.sharedInstance.resultsArray.append(result)
        
        Trackers.sharedInstance.currentTrial! += 1
        
        activeTrial = false
        
    }
    // button method for Gaze trials
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Trackers.sharedInstance.currentTest = 1
        Trackers.sharedInstance.currentTrial = 1
        
        DBManager.getTrialInfoForTest(test: Trackers.sharedInstance.currentTest!)
        
    }
    // Sets current test to 1 (Gaze) and retrieves media for this test on view load
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
