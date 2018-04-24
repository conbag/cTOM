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
    
    @IBOutlet weak var pauseButton: UIButton!
    var videoPaused = false
    var pauseSeconds: Double?
    var resumeSeconds: Double?
    var pausedTime: Double?
    // variable to keep track of pause times for trials
    
    var videoDate: Date?
    var buttonDate: Date?
    var dbDate: String?
    // timestamp that will be recorded in db for each trial
    
    var longestTrialDuration: Double?
    // store longest trial duration in seconds
    
    var trialOrder = 0
    
    @IBOutlet weak var escapeTest: UIButton!
    
    var counter = 0
    var timer = Timer()
    // timer object used to display cross for 2 seconds
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var audioPlayer: AVAudioPlayer?
    // video and audio players
    
    var myContext = 0
    var observerAdded = false
    // variable required for adding observer to playerlayer to detect when video has started. Needed due to slight lag in calling player and video starting

    @IBOutlet weak var finishMessage: UILabel!
    @IBOutlet weak var mainMenu: UIButton!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var crossView: UIView!
    // subviews for video and cross displays
    
    var activeTrial = true
    
    @IBAction func gazeButton(_ sender: UIButton) {
 
        if activeTrial == true {
            
            buttonDate = Date()
            
            let currentTrial = Trackers.currentTrial!
            let correctAnswer = DBManager.trialWithAnswer[currentTrial]
            // retrieve correct answer from trialWithAnswer dict from DBManager singleton class
            
            let result: Result
 
            let reactionTime = (round(1000 * (currentTimeInMiliseconds(date: buttonDate!) - currentTimeInMiliseconds(date: videoDate!) - pausedTime!))) / 1000
            // get seconds(to 3 decimal places) by taking away video start time minus button time. Less any time trial was paused
            
            if sender.tag as Int == Int(correctAnswer!)! {
                playAudio()
                // plays 'ding' audio for correct answer
                
                result = Result(answerTag: String(sender.tag), accuracyMeasure: "TRUE", trialID: currentTrial, secondMeasure: reactionTime, order: (trialOrder + 1), date: dbDate!, session: Trackers.currentSession!)
            } else {
                result = Result(answerTag: String(sender.tag), accuracyMeasure: "FALSE", trialID: currentTrial, secondMeasure: reactionTime, order: (trialOrder + 1), date: dbDate!, session: Trackers.currentSession!)
            }
            // create new instance of result object to store trial data
            
            Trackers.resultsArray.append(result)
            
            activeTrial = false

        }

    }
    // button method for Gaze trials
    
    @IBAction func escapeButton(_ sender: UIButton) {
        
        DBManager.storeResultsToDatabase()
        Trackers.resultsArray.removeAll()
        Trackers.randomizedTrialList.removeAll()
        DBManager.trialList.removeAll()
        DBManager.trialWithAnswer.removeAll()
        DBManager.trialWithVideo.removeAll()
        // Reset various arrays on test finish
    }
    // escape button that is enabled when test is paused
    
    func currentTimeInMiliseconds(date: Date) -> Double {
        
        let since1970 = date.timeIntervalSince1970
        return Double(since1970)
        
    }
    // returns seconds for passed in date since 1970
    
    func startTimingTrials() {
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(callVideo), userInfo: nil, repeats: false)
    }
    // delays the callVideo method for 1 second
    
    
    @objc func callVideo() {
        
        if (trialOrder + 1) < Trackers.randomizedTrialList.count {
            trialOrder += 1
            Trackers.currentTrial! = Trackers.randomizedTrialList[trialOrder]
            activeTrial = true
            
            playTestVideo(videoView: videoView)
        } else {
            finishMessage.isHidden = false
            mainMenu.isHidden = false
            mainMenu.isEnabled = true
            
            DBManager.storeResultsToDatabase()
            Trackers.resultsArray.removeAll()
            Trackers.randomizedTrialList.removeAll()
            DBManager.trialList.removeAll()
            DBManager.trialWithAnswer.removeAll()
            DBManager.trialWithVideo.removeAll()
            // Reset various arrays on test finish
        }
        // logic for when trials are finished. Displays text label and stores Result array to DB
        
        crossView.layer.sublayers = nil
    }
    
    
    func playTestVideo(videoView: UIView) {
        pausedTime = 0;
        // reset accumulated pause time
        
        let path = Bundle.main.path(forResource: DBManager.trialWithVideo[Trackers
            .currentTrial!], ofType: "mp4")
        
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = .resize
        playerLayer.frame = CGRect(x: CGFloat(3), y: CGFloat(3), width: CGFloat(videoView.bounds.width - 6), height: CGFloat(videoView.bounds.height - 6))
        // setting video player frame to within videoView's border of length 3

        videoView.layer.addSublayer(playerLayer)
        
        player.volume = 0.0
        // disable volume on gaze videos as direct is indicated
        player.play()
        
        self.playerLayer.addObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay), options: NSKeyValueObservingOptions.new, context: &myContext)
        // adding observer to indicate when video begins rather than called
        observerAdded = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if playerLayer.isReadyForDisplay == true {
                videoView.layer.borderWidth = 3
                // adding border to videoView
                
                timer = Timer.scheduledTimer(timeInterval: (longestTrialDuration! + 1), target: self, selector: #selector(videoDidFinishPlaying), userInfo: nil, repeats: false)
                // intialise answer timer for length of longest video plus 1 second
                
                videoDate = Date()
                dbDate = dateToString(date: videoDate!)
                // set start date to when video begins
            }
        }
    }
    // Code that runs when video actually begins rather than when called
    
    
    @objc func videoDidFinishPlaying(){
        //Called when player finished playing
        
        if observerAdded == true {
            self.playerLayer.removeObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay))
            // remove observer from player layer in order to not build on top of each other
            
            observerAdded = false
        }
        // check if observer has been registered for playerlayer and remove if yes
        
        if activeTrial == true {
            
            let result = Result(answerTag: "0", accuracyMeasure: "FALSE", trialID: Trackers.currentTrial!, secondMeasure: 0.0, order: (trialOrder + 1), date: dbDate!, session: Trackers.currentSession!)
            
            Trackers.resultsArray.append(result)
            activeTrial = false
            
        }
        // if trial is not answered store result with 0 for 'answerTag' and 0.0 for time measure
        
        playerLayer.player = nil
        playerLayer.removeFromSuperlayer()
        // was problem area. need to remove playerlayer from its super layer or there will be memory leak
        // removes videoplayer to make way for cross image
        
        let cross = UIImage(named: "Cross")?.cgImage
    
        let imageLayer = CALayer()
    
        imageLayer.contents = cross
        imageLayer.frame = crossView.bounds
    
        crossView.layer.addSublayer(imageLayer)
    
        videoView.layer.borderWidth = 0
        // remove border
        
        startTimingTrials()
    }
    // function that is called when video is finished playing
    
    
    func playAudio() {
        let url = Bundle.main.url(forResource: "Ding Sound Effect", withExtension: "m4a")!
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let dingSound = audioPlayer else { return }
            
            dingSound.prepareToPlay()
            dingSound.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    // when called plays "Ding Sound Effect" audio file

    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateDB: String = dateFormatter.string(from: date)
        
        return dateDB
    }
    // to convert swift date object to String that is storable in sqlite DB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        // to force landscape view only
        
        trialOrder = 0
        videoPaused = false
        
        Trackers.currentTest = 1
        DBManager.getTrialInfoForTest(test: Trackers.currentTest!)
        // set current test to 1 as this is Gaze view and retrieve the info from DB
        
        longestTrialDuration = DBManager.getLongestMediaForTest(test: Trackers.currentTest!)
        // get longest trial duration for test in seconds
        
        DBManager.getVideoDataForTest()
        
        Trackers.randomizeArray(array: DBManager.trialList)
        Trackers.currentTrial = Trackers.randomizedTrialList[0]
        // call randomizeArray function on Gaze trial list and set the current trial to first element in this array
        
        finishMessage.isHidden = true
        mainMenu.isHidden = true
        mainMenu.isEnabled = false
        
        let oneFingerTap = UITapGestureRecognizer(target: self, action:#selector(ViewControllerGaze.oneFingerTapDetected(sender:)))
        oneFingerTap.numberOfTouchesRequired = 1
        let twoFingerTap = UITapGestureRecognizer(target: self, action:#selector(ViewControllerGaze.twoFingerTapDetected(sender:)))
        twoFingerTap.numberOfTouchesRequired = 2
        
        escapeTest.isEnabled = false
        
        pauseButton.addGestureRecognizer(oneFingerTap)
        pauseButton.addGestureRecognizer(twoFingerTap)
        // creating gestures for pause button
    }
    // Sets current test to 1 (Gaze) and retrieves media for this test on view load
    
    @objc func oneFingerTapDetected(sender:UITapGestureRecognizer) {
        let button = self.view.viewWithTag(1) as? UIButton
        gazeButton(button!)
    }
    
    @objc func twoFingerTapDetected(sender:UITapGestureRecognizer) {
        
        let videoSeconds = currentTimeInMiliseconds(date: videoDate!)
        // seconds since video started
        
        let oneFingerTap = UITapGestureRecognizer(target: self, action:#selector(ViewControllerGaze.oneFingerTapDetected(sender:)))
        oneFingerTap.numberOfTouchesRequired = 1
        
        if videoPaused == false {
            timer.invalidate()
            player.pause()
            // pause video and cancel timer

            pauseSeconds = currentTimeInMiliseconds(date: Date())
            // seconds when video paused
            
            activateGazeButtons(bool: false)
            // deactivates all gazebuttons when pauseButton is presed
            pauseButton.removeGestureRecognizer(oneFingerTap)
            
            escapeTest.isEnabled = true
            // enable escaping only when test is paused
            
            videoPaused = true
        } else {
            resumeSeconds = currentTimeInMiliseconds(date: Date())
            // seconds when video resumed
            
            pausedTime = pausedTime! + (resumeSeconds! - pauseSeconds!)
            // calculates accumulated pause time per trial. Resets when new video is called
            
            timer = Timer.scheduledTimer(timeInterval: (longestTrialDuration! - (resumeSeconds! - videoSeconds - pausedTime!)), target: self, selector: #selector(videoDidFinishPlaying), userInfo: nil, repeats: false)
            // restart timer with original seconds less time played before paused
            player.play()

            activateGazeButtons(bool: true)
            // activates all gazebuttons when pauseButton is presed
            pauseButton.addGestureRecognizer(oneFingerTap)
            
            escapeTest.isEnabled = false
            // disable escaping
            
            videoPaused = false
        }
    }
    
    // above two functions apply to pauseButton depending on number of taps. Two taps required for pause
    
    func activateGazeButtons(bool: Bool) {
        let rightButton = self.view.viewWithTag(1) as? UIButton
        rightButton?.isEnabled = bool
        
        let leftButton = self.view.viewWithTag(2) as? UIButton
        leftButton?.isEnabled = bool
        
        let topButton = self.view.viewWithTag(3) as? UIButton
        topButton?.isEnabled = bool
        
        let centerButton = self.view.viewWithTag(4) as? UIButton
        centerButton?.isEnabled = bool
        
        let downButton = self.view.viewWithTag(5) as? UIButton
        downButton?.isEnabled = bool
    }
    // (de)activates all gazebuttons
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playTestVideo(videoView: videoView)
    }
    // need to put play method here in order for constraints to update first
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.landscapeRight
    }
    // above 3 functions used to force landscape view only
    
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
