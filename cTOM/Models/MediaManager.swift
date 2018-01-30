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

    static var player: AVPlayer!
    static var playerLayer: AVPlayerLayer!
    
    
    private init() {}

    
    
    static func playTestVideo(videoView: UIView) {
        
        let path = Bundle.main.path(forResource: DBManager.videoList[Trackers.sharedInstance.currentTrial! - 1], ofType: "mp4")
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        playerLayer.frame = videoView.bounds
        
        videoView.layer.addSublayer(playerLayer)

        player.play()

    }
    
    
    
    
}
