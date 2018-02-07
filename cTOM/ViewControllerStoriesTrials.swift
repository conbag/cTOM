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

class ViewControllerStoriesTrials: UIViewController {
    
    var trialOrder = 0
    
    var counter = 0
    var timer = Timer()
    // timer object used to question and answer slots
    
    var videoDate: Date?
    var buttonDate: Date?
    var dbDate: String?
    // timestamp that will be recorded in db for each trial
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var audioPlayer: AVAudioPlayer?
    // video and audio players
    
    var activeTrial = false
    
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
            
            let reactionTime = round(1000 * (currentTimeInMiliseconds(date: buttonDate!) - currentTimeInMiliseconds(date: videoDate!))) / 1000
            // get seconds(to 3 decimal places) by taking away video start time minus button time
            
            if sender.tag as Int == correctAnswer {
                playAudio(path: "Ding Sound Effect")
                // plays 'ding' audio for correct answer
                
                result = Result(answerTag: sender.tag, accuracyMeasure: "True", trialID: currentTrial, secondMeasure: reactionTime, order: (trialOrder + 1), date: dbDate!)
            } else {
                result = Result(answerTag: sender.tag, accuracyMeasure: "False", trialID: currentTrial, secondMeasure: reactionTime, order: (trialOrder + 1), date: dbDate!)
            }
            // create new instance of result object to store trial data
            
            Trackers.resultsArray.append(result)
            
            activeTrial = false
     
        }
    }
  
    func currentTimeInMiliseconds(date: Date) -> Double {
        
        let since1970 = date.timeIntervalSince1970
        return Double(since1970)
        
    }
    // returns seconds for passed in date since 1970
    
    
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
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        //Called when player finished playing
        
        questionLabel.text = DBManager.trialWithText[Trackers.currentTrial!]
        playAudio(path: DBManager.trialWithAudio[Trackers.currentTrial!]!)
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.showAllAnswerButton()
            self.activeTrial = true
            self.videoDate = Date()
            self.dbDate = self.dateToString(date: self.videoDate!)
            
            self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.closeQuestion), userInfo: nil, repeats: false)
        }
        
    }
    
    @objc func closeQuestion() {
        if activeTrial == true {
            
            let result = Result(answerTag: 0, accuracyMeasure: "False", trialID: Trackers.currentTrial!, secondMeasure: 0.0, order: (trialOrder + 1), date: dbDate!)
            
            Trackers.resultsArray.append(result)
        }
        
        if Trackers.currentTrial == DBManager.trialList[DBManager.trialList.count] {
            
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
            
        } else {
        
            activeTrial = true
            
            trialOrder += 1
            Trackers.currentTrial! += 1
            
            hideAllAnswerButton()
            questionLabel.text = ""
            playTestVideo(videoView: videoView)
        }

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
        
        var imageList = DBManager.trialWithImages[Trackers.currentTrial!]
        
        for index in 1...4 {
            let image = UIImage(named: imageList![index - 1]) as UIImage?
            
            let button = self.view.viewWithTag(index) as? UIButton
            button!.isHidden = false
            button?.setBackgroundImage(image!, for: UIControlState.normal)
        }
    }
    // displays all 4 answer buttons
    
    func playAudio(path: String) {
        let url = Bundle.main.url(forResource: path, withExtension: "m4a")!
        
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        playTestVideo(videoView: videoView)
        
        hideAllAnswerButton()
    }

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
