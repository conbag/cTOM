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
    
    var videoDate: Date?
    var buttonDate: Date?
    var dbDate: String?
    // timestamp that will be recorded in db for each trial
    
    var trialOrder = 0
    
    var counter = 0
    var timer = Timer()
    // timer object used to display cross for 2 seconds
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var audioPlayer: AVAudioPlayer?
    // video and audio players
    
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
 
            let reactionTime = round(1000 * (currentTimeInMiliseconds(date: buttonDate!) - currentTimeInMiliseconds(date: videoDate!))) / 1000
            // get seconds(to 3 decimal places) by taking away video start time minus button time
            
            if sender.tag as Int == correctAnswer {
                playAudio()
                // plays 'ding' audio for correct answer
                
                result = Result(answerTag: sender.tag, accuracyMeasure: "True", trialID: currentTrial, secondMeasure: reactionTime, order: (trialOrder + 1), date: dbDate!, session: Trackers.currentSession!)
            } else {
                result = Result(answerTag: sender.tag, accuracyMeasure: "False", trialID: currentTrial, secondMeasure: reactionTime, order: (trialOrder + 1), date: dbDate!, session: Trackers.currentSession!)
            }
            // create new instance of result object to store trial data
            
            Trackers.resultsArray.append(result)
            
            activeTrial = false

        }

    }
    // button method for Gaze trials
    
    
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
            
            crossView.layer.sublayers = nil
            
            DBManager.storeResultsToDatabase()
            Trackers.resultsArray.removeAll()
            Trackers.randomizedTrialList.removeAll()
            DBManager.trialList.removeAll()
            DBManager.trialWithAnswer.removeAll()
            DBManager.trialWithVideo.removeAll()
            // Reset various arrays on test finish
        }
        // logic for when trials are finished. Displays text label and stores Result array to DB
    }
    
    
    func playTestVideo(videoView: UIView) {
        let path = Bundle.main.path(forResource: DBManager.trialWithVideo[Trackers
            .currentTrial!], ofType: "mp4")
        
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        playerLayer.frame = videoView.bounds
        
        videoView.layer.addSublayer(playerLayer)
        
        player.volume = 0.0
        // disable volume on gaze videos as direct is indicated
        player.play()
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        videoDate = Date()
        dbDate = dateToString(date: videoDate!)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        //Called when player finished playing
        
        if activeTrial == true {
            
            let result = Result(answerTag: 0, accuracyMeasure: "False", trialID: Trackers.currentTrial!, secondMeasure: 0.0, order: (trialOrder + 1), date: dbDate!, session: Trackers.currentSession!)
            
            Trackers.resultsArray.append(result)
            activeTrial = false
            
        }
        // if trial is not answered store result with 0 for 'answerTag' and 0.0 for time measure
        
        NotificationCenter.default.removeObserver(self)
        playerLayer.player = nil
        playerLayer.removeFromSuperlayer()
        // problem area. need to remove playerlayer from its super layer or there will be memory leak
        // removes videoplayer to make way for cross image
        
        let cross = UIImage(named: "Cross")?.cgImage
    
        let imageLayer = CALayer()
        //let blankLayer = CALayer()
    
        imageLayer.contents = cross
        imageLayer.frame = crossView.bounds
    
        crossView.layer.addSublayer(imageLayer)
    
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
        
        Trackers.currentTest = 1
        DBManager.getTrialInfoForTest(test: Trackers.currentTest!)
        // set current test to 1 as this is Gaze view and retrieve the info from DB
        
        DBManager.getVideoDataForTest()
        
        Trackers.randomizeArray(array: DBManager.trialList)
        Trackers.currentTrial = Trackers.randomizedTrialList[0]
        // call randomizeArray function on Gaze trial list and set the current trial to first element in this array
        
        finishMessage.isHidden = true
        mainMenu.isHidden = true
        mainMenu.isEnabled = false
        
    }
    // Sets current test to 1 (Gaze) and retrieves media for this test on view load
    
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
