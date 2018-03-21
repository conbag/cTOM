//
//  ViewControllerGazePractice.swift
//  cTOM
//
//  Created by Conor O'Grady on 05/02/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewControllerGazePractice: UIViewController {
    
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var imageViewGazePractice: UIView!

    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var straightInstruction: UILabel!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    
    var buttonTag: Int?

    @IBAction func practiceButton(_ sender: UIButton) {
        if sender.tag == buttonTag! {
            
            sender.isHidden = true
            
            if sender.tag == 1 {
                buttonTag! += 1
                
                self.view.viewWithTag(buttonTag!)?.isHidden = false
                let button = self.view.viewWithTag(4) as? UIButton
                let img = UIImage(named: "c-TOM_Gaze_practice_looking_left")
                
                playAudio(path: "Press Here If The Actor Is Looking To The Left")
                
                button?.setBackgroundImage(img, for: .normal)
            } else if sender.tag == 2 {
                buttonTag! += 1
                
                self.view.viewWithTag(buttonTag!)?.isHidden = false
                let button = self.view.viewWithTag(4) as? UIButton
                let img = UIImage(named: "c-TOM_Gaze_practice_looking_up")
                
                playAudio(path: "Press Here If The Actor Is Looking Above")
                
                button?.setBackgroundImage(img, for: .normal)
            } else if sender.tag == 3 {
                buttonTag! += 1
                self.view.viewWithTag(buttonTag!)?.isHidden = false
                
                straightInstruction.isHidden = false
                let button = self.view.viewWithTag(4) as? UIButton
                let img = UIImage(named: "c-TOM_Gaze_practice_looking_straight_ahead")
                
                playAudio(path: "Press On The Image Below If The Actor Is Looking Directly At You")
                
                button?.setBackgroundImage(img, for: .normal)
            } else {
                buttonTag = 1
                
                imageViewGazePractice.layer.borderWidth = 0
                readyButton.isEnabled = true
                readyButton.isHidden = false
                
                audioPlayer?.stop()
                
                straightInstruction.isHidden = true
            }
        }
    }
    // logic for displaying and hiding the various practice buttons and changing centre image
    
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
    // function to play instuctions audio on different buttons

    override func viewDidLoad() {
        super.viewDidLoad()
        
        readyButton.isEnabled = false
        readyButton.isHidden = true
        readyButton.layer.cornerRadius = 10
        
        leftButton.isHidden = true
        leftButton.layer.cornerRadius = 15
        
        rightButton.isHidden = false
        rightButton.layer.cornerRadius = 15
        
        topButton.isHidden = true
        topButton.layer.cornerRadius = 15
        
        centerButton.isHidden = false
        
        imageViewGazePractice.layer.borderWidth = 3
        
        straightInstruction.isHidden = true
        straightInstruction.adjustsFontSizeToFitWidth = true

        buttonTag = 1
        playAudio(path: "Press Here If The Actor Is Looking To The Right")
        
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
