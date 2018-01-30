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
    
    @IBAction func vidAct(_ sender: Any) {

        MediaManager.playTestVideo(videoView: videoView)
        
        print(MediaManager.videoList)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Trackers.sharedInstance.currentTest = 1
        
        MediaManager.getMediaForTest(test: Trackers.sharedInstance.currentTest!)
        
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
