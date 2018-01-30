//
//  MediaManager.swift
//  cTOM
//
//  Created by Conor O'Grady on 30/01/2018.
//  Copyright © 2018 Conor O'Grady. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import UIKit


final class MediaManager {
    
    static let sharedInstance = MediaManager()
    
    static var videoList = [String] ()
    static var player: AVPlayer!
    static var playerLayer: AVPlayerLayer!
    
    
    private init() {}

    
    static func getMediaForTest(test: Int) {
        
        if Trackers.sharedInstance.currentTest == test {
            
            let query = "select * from Trial where test_id = \(test)"
            // will need to change this to join for stories trials
            
            let results:FMResultSet? = DBManager.ctomDB.executeQuery(query, withArgumentsIn: [])
            
            while results?.next() == true {
                videoList.append((results?.string(forColumn: "trial_name"))!)
            }
            
        }
        
    }
    // extracts video paths for specific test and stors in array
    
    
    static func playTestVideo(videoView: UIView) {
        
        let path = Bundle.main.path(forResource: videoList[3], ofType: "mp4")
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        playerLayer.frame = videoView.bounds
        
        videoView.layer.addSublayer(playerLayer)

        player.play()

        
    }
    
    
    
    
}
