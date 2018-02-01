//
//  ViewControllerGaze.swift
//  cTOM
//
//  Created by Conor O'Grady on 30/01/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewControllerGaze: UIViewController {
    
    var counter = 0
    var timer = Timer()
    // timer object used to display cross for 2 seconds
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var crossView: UIView!
    // subviews for video and cross displays
    
    var activeTrial = true
    
    @IBAction func vidAct(_ sender: UIButton) {

        playTestVideo(videoView: videoView)
        
        sender.isEnabled = false
        sender.isHidden = true
        
    }
    // button to begin trials. Hidden once pressed
    
    
    @IBAction func testButton(_ sender: Any) {
        
        DBManager.storeResultsToDatabase()
        
    }
    // Tester button to push results to DB -> will need to be deleted
    
    @IBAction func gazeButton(_ sender: UIButton) {
        
 
        if activeTrial == true {
            
            let currentTrial = Trackers.currentTrial!
            let correctAnswer = DBManager.trialWithAnswer[currentTrial]
            // retrieve correct answer from trialWithAnswer dict from DBManager singleton class
            
            let result: Result
            
            if sender.tag as Int == correctAnswer {
                result = Result(answerTag: sender.tag, accuracyMeasure: "Correct", trialID: currentTrial)
            } else {
                result = Result(answerTag: sender.tag, accuracyMeasure: "Incorrect", trialID: currentTrial)
            }
            // create new instance of result object to store trial data
            
            Trackers.resultsArray.append(result)
            
            activeTrial = false
            
            //startTimingTrials()
            
        }

    }
    // button method for Gaze trials
    
    
    
    func startTimingTrials() {
        
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(callVideo), userInfo: nil, repeats: false)
    }
    // delays the callVideo method for 2 seconds
    
    @objc func callVideo() {
        
        Trackers.currentTrial! += 1
        activeTrial = true
        
        playTestVideo(videoView: videoView)
    }
    
    
    func playTestVideo(videoView: UIView) {
        
        let path = Bundle.main.path(forResource: DBManager.videoList[Trackers.currentTrial! - 1], ofType: "mp4")
        
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        playerLayer.frame = videoView.bounds
        
        videoView.layer.addSublayer(playerLayer)
        
        player.volume = 0.0
        // disable volume on gaze videos as direct is indicated
        player.play()
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        //Called when player finished playing
        
        let cross = UIImage(named: "Cross")?.cgImage
        
        let imageLayer = CALayer()
        let blankLayer = CALayer()
        
        imageLayer.contents = cross
        imageLayer.frame = crossView.bounds
        
        crossView.layer.addSublayer(imageLayer)
        
        videoView.layer.replaceSublayer(playerLayer, with: blankLayer)
        
        startTimingTrials()
        
    }
    // function that is called when video is finished playing
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Trackers.currentTest = 1
        Trackers.currentTrial = 1
        
        DBManager.getTrialInfoForTest(test: Trackers.currentTest!)
        
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
