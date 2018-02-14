//
//  ViewControllerStories.swift
//  cTOM
//
//  Created by Conor O'Grady on 05/02/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewControllerStories: UIViewController {
    
    var audioPlayer: AVAudioPlayer?
    
    @IBAction func beginButton(_ sender: UIButton) {
        
        audioPlayer?.stop()
        
    }
    // stop audio when 'begin' button is pressed
    
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
    // function to play instuctions audio on view load

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playAudio(path: "c-TOM Stories introduction")
        // play instruction audio when view loads
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
