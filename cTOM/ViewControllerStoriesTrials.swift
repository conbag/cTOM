//
//  ViewControllerStoriesTrials.swift
//  cTOM
//
//  Created by Conor O'Grady on 06/02/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewControllerStoriesTrials: UIViewController, AVAudioPlayerDelegate {
    
    var trialOrder = 0
    
    var counter = 0
    var timer = Timer()
    // timer object used to question and answer slots
    
    var questionDate: Date?
    var buttonDate: Date?
    var dbDate: String?
    // timestamp that will be recorded in db for each trial
    
    var videoPaused = false
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var dingAudioPlayer: AVAudioPlayer?
    // video and audio players
    
    var audioPlayer: AVAudioPlayer?
    // seperate audioPlayers so I can call delegate to listen for when audio finishes - then display answer boxes
    
    var activeTrial = false
    
    @IBOutlet weak var pausedButton: UIButton!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var finishMessage: UILabel!
    @IBOutlet weak var mainMenuButton: UIButton!

    @IBAction func answerButton(_ sender: UIButton) {
        
        if activeTrial == true {
            
            let currentTrial = Trackers.currentTrial!
            let correctAnswer = DBManager.trialWithAnswer[currentTrial]
            // retrieve correct answer from trialWithAnswer dict from DBManager singleton class
        
            buttonDate = Date()
            
            let result: Result
            
            let reactionTime = round(1000 * (currentTimeInMiliseconds(date: buttonDate!) - currentTimeInMiliseconds(date: questionDate!))) / 1000
            // get seconds(to 3 decimal places) by taking away question start time minus button time
            
            if sender.currentBackgroundImage?.accessibilityIdentifier == correctAnswer! {
                playDingSound()
                // plays 'ding' audio for correct answer
                
                result = Result(answerTag: (sender.currentBackgroundImage?.accessibilityIdentifier)!, accuracyMeasure: "True", trialID: currentTrial, secondMeasure: reactionTime, order: (trialOrder + 1), date: dbDate!, session: Trackers.currentSession!)
            } else {
                result = Result(answerTag: (sender.currentBackgroundImage?.accessibilityIdentifier)!, accuracyMeasure: "False", trialID: currentTrial, secondMeasure: reactionTime, order: (trialOrder + 1), date: dbDate!, session: Trackers.currentSession!)
            }
            // create new instance of result object to store trial data
            
            Trackers.resultsArray.append(result)
            
            activeTrial = false
        }
    }
    
    @IBAction func pauseButton(_ sender: UIButton) {
        if videoPaused == false {
            player.pause()
            videoPaused = true
        } else {
            player.play()
            videoPaused = false
        }
    }
    // pauses video player
  
    func currentTimeInMiliseconds(date: Date) -> Double {
        let since1970 = date.timeIntervalSince1970
        return Double(since1970)
    }
    // returns seconds for passed in date since 1970
    
    
    func playTestVideo(videoView: UIView) {
        
        videoView.layer.borderWidth = 3
        videoView.layer.cornerRadius = 3
        // add border and radius to video outline
        
        let path = Bundle.main.path(forResource: DBManager.trialWithVideo[Trackers
            .currentTrial!], ofType: "mp4")
        // searched trialWithVideo dict for correct video to play for current trial
        
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        playerLayer.frame = videoView.bounds
        // set video to bounds of videoView
        
        videoView.layer.addSublayer(playerLayer)
        
        player.volume = 0.0
        // disable volume on gaze videos as direct is indicated
        player.play()
        pausedButton.isEnabled = true
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        // notification for when video finishes
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        //Called when player finished playing
        
        questionLabel.text = DBManager.trialWithText[Trackers.currentTrial!]
        questionLabel.adjustsFontSizeToFitWidth = true
        playSound(path: DBManager.trialWithAudio[Trackers.currentTrial!]!)
        // display question audio and text for current trial
        
        pausedButton.isEnabled = false
    }
    
    @objc func closeQuestion() {
        if activeTrial == true {
            
            let result = Result(answerTag: "0", accuracyMeasure: "False", trialID: Trackers.currentTrial!, secondMeasure: 0.0, order: (trialOrder + 1), date: dbDate!, session: Trackers.currentSession!)
            
            Trackers.resultsArray.append(result)
        }
        // when user fails to press button in time we record the above as their result
        
        if Trackers.currentTrial == DBManager.trialList[DBManager.trialList.count - 1] {
            
            finishMessage.isHidden = false
            mainMenuButton.isHidden = false
            mainMenuButton.isEnabled = true
            
            videoView.layer.sublayers = nil
            questionLabel.text = ""
            hideAllAnswerButton()
            
            DBManager.storeResultsToDatabase()
            Trackers.resultsArray.removeAll()
            DBManager.trialList.removeAll()
            DBManager.trialWithAnswer.removeAll()
            DBManager.trialWithVideo.removeAll()
            DBManager.trialWithImages.removeAll()
            DBManager.trialWithText.removeAll()
            DBManager.trialWithAudio.removeAll()
            
            // on completion of last trial we display finish message and main menu button. Also reset all DBManager and Tracker variables
            
        } else {
            
            NotificationCenter.default.removeObserver(self)
            playerLayer.player = nil
            playerLayer.removeFromSuperlayer()
            // removes player and observer objects to clear memory
        
            activeTrial = false
            
            trialOrder += 1
            Trackers.currentTrial! += 1
            
            hideAllAnswerButton()
            questionLabel.text = ""
            playTestVideo(videoView: videoView)
        }
        // increment current trial and trial order by one and hide answer buttons

    }
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateDB: String = dateFormatter.string(from: date)
        
        return dateDB
    }
    
    func hideAllAnswerButton() {
        for index in 1...4 {
            
            let button = self.view.viewWithTag(index) as? UIButton
            
            button!.isHidden = true
        }
    }
    // hides all 4 answer buttons
    
    func showAllAnswerButton() {
        
        let imageList = DBManager.trialWithImages[Trackers.currentTrial!]
        
        var randomisedImageArray = randomizeStringArray(array: imageList!)
        
        for index in 1...4 {
            let image = UIImage(named: randomisedImageArray[index - 1]) as UIImage?
            // randomize the correct answer images for each of the 4 buttons
            image?.accessibilityIdentifier = randomisedImageArray[index - 1]
            // tag each image with its filename so can be identified
            
            let button = self.view.viewWithTag(index) as? UIButton
            button!.isHidden = false
            button?.setBackgroundImage(image!, for: UIControlState.normal)
            button?.layer.borderWidth = 3
            button?.layer.cornerRadius = 3
        }
    }
    // displays all 4 answer buttons
    
    func playDingSound() {
        let url = Bundle.main.url(forResource: "Ding Sound Effect", withExtension: "m4a")!
        
        do {
            dingAudioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let dingSound = dingAudioPlayer else { return }
            
            dingSound.prepareToPlay()
            dingSound.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    // function to play ding sound on correct answer

    func playSound(path: String) {
        guard let url = Bundle.main.url(forResource: path, withExtension: "m4a") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            // this codes for making this app ready to takeover the device audio
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            audioPlayer?.delegate = self

            audioPlayer!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    // when called plays audio file of passed in path
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        showAllAnswerButton()
        activeTrial = true
        questionDate = Date()
        dbDate = dateToString(date: questionDate!)
        // displaying answer buttons and setting trial to active when audio finishes
        
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(closeQuestion), userInfo: nil, repeats: false)
        // wait 5 seconds before calling closeQuestion function below
    }
    
    func randomizeStringArray(array : [String]) -> [String] {
        var randomizedArray : [String] = []
        var copyOfArray = array
        while !copyOfArray.isEmpty {
            let arrayCount = copyOfArray.count
            let randomElement = Int(arc4random_uniform(UInt32(arrayCount)))
            let arraySlice = copyOfArray[randomElement]
            randomizedArray.append(arraySlice)
            copyOfArray.remove(at : randomElement)
        }
        
        return randomizedArray
    }
    // function to randomize elements in String array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        // to force landscape view only
        
        finishMessage.isHidden = true
        mainMenuButton.isHidden = true
        mainMenuButton.isEnabled = false
        
        trialOrder = 0

        Trackers.currentTest = 2
    
        DBManager.getTrialInfoForTest(test: Trackers.currentTest!)
        // set current test to 2 as this is Stories view and retrieve the info from DB
        Trackers.currentTrial = DBManager.trialList[trialOrder]
        
        DBManager.getTextDataForTest()
        DBManager.getAudioDataForTest()
        DBManager.getVideoDataForTest()
        DBManager.getImageDataForTest()
        
        hideAllAnswerButton()
        pausedButton.isEnabled = false
    }
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playTestVideo(videoView: videoView)
    }
    // need to put play method here in order for constraints to update first

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
