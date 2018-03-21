//
//  ViewControllerGazeControl.swift
//  cTOM
//
//  Created by Conor O'Grady on 16/03/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewControllerGazeControl: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer?
    var buttonAudioPlayer: AVAudioPlayer?
    // seperate audioPlayers so I can call delegate to listen for when initial audio finishes
    
    @IBOutlet weak var imageView: UIView!
    
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var startLabel: UILabel!
    
    var buttonTag: Int?
    
    @IBAction func gazeButton(_ sender: UIButton) {
        if sender.tag == buttonTag! {
            
            sender.isHidden = true
            
            let button = self.view.viewWithTag(4) as? UIButton
            
            if sender.tag == 1 {
                buttonTag! += 1
                buttonAudioPlayer?.stop()
                
                self.view.viewWithTag(buttonTag!)?.isHidden = false
                
                let img = UIImage(named: "c-TOM Gaze checkerboard control left")
                button?.setBackgroundImage(img, for: .normal)
                
                playAudio(path: "Press Here If The Circle Moves To The Left")
            } else if sender.tag == 2 {
                buttonTag! += 1
                buttonAudioPlayer?.stop()
                
                self.view.viewWithTag(buttonTag!)?.isHidden = false

                let img = UIImage(named: "c-TOM Gaze checkerboard control up")
                button?.setBackgroundImage(img, for: .normal)
                
                playAudio(path: "Press Here If The Circle Moves Up")
            } else {
                button?.isHidden = true
                
                buttonTag = 1
                buttonAudioPlayer?.stop()
                
                imageView.layer.borderWidth = 0
                
                readyButton.isEnabled = true
                readyButton.isHidden = false
                
                audioPlayer?.stop()
            }
        }
    }
    // logic for displaying and hiding the various practice buttons and changing centre image
    
    func playAudio(path: String) {
        let url = Bundle.main.url(forResource: path, withExtension: "m4a")!
        
        do {
            buttonAudioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let sound = buttonAudioPlayer else { return }
            
            sound.prepareToPlay()
            sound.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    // function to play button audio
    
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
        let button = self.view.viewWithTag(4) as? UIButton
        let img = UIImage(named: "c-TOM Gaze checkerboard control right")
        
        button?.setBackgroundImage(img, for: .normal)

        activateGazeButtons(bool: true)
        
        leftButton.isHidden = true
        topButton.isHidden = true
        
        playAudio(path: "Press Here If The Circle Moves To The Right")
        startLabel.isHidden = true
    }
    // display right button and play right audio when initial audio finishes
    
    func activateGazeButtons(bool: Bool) {
        for index in 1...3 {
            
            let button = self.view.viewWithTag(index) as? UIButton
            
            button!.isEnabled = bool
            button!.isHidden = !bool
        }
    }
    // function to (de)activate gaze buttons

    override func viewDidLoad() {
        super.viewDidLoad()
        activateGazeButtons(bool: false)

        readyButton.isHidden = true
        readyButton.isEnabled = false
        // hide and disable ready button

        buttonTag = 1
        
        imageView.layer.borderWidth = 3

        playSound(path: "Sometimes You Will See A Circle")

        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        // to force landscape view only
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


