//
//  ViewControllerGazeIntro.swift
//  cTOM
//
//  Created by Conor O'Grady on 16/03/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewControllerGazeIntro: UIViewController {
    
    var audioPlayer: AVAudioPlayer?
    
    @IBAction func beginPractice(_ sender: UIButton) {
        audioPlayer?.stop()
    }
    
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
    // function to play instuctions audio
    
    override func viewDidLoad() {
        playAudio(path: "c-TOM Gaze Introduction")
    }

    
}
