//
//  AVPlayerObserver.swift
//  
//
//  Created by Sebastian Ceglarz on 24/05/2021.
//

import Foundation
import AVKit
import os.log

public class AVPlayerObserver : NSObject{
    
    private var stormLibrary : StormLibrary!
    
    public init(stormLibrary: StormLibrary){
        super.init()
        self.stormLibrary = stormLibrary
        
     
        stormLibrary.getAvPlayer().addObserver(self,
                                               forKeyPath: "rate",
                                               options: [],
                                               context: nil)
        stormLibrary.getAvPlayer().addObserver(self,
                                               forKeyPath: "currentItem.status",
                                               options: [],
                                               context: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       
        if keyPath == #keyPath(AVPlayerItem.status) {
            
            let playerItem = object as! AVPlayerItem
            let status: AVPlayerItem.Status
            
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            switch status {
                case .failed:
       
                    stormLibrary.stop()
                    
                    if let error = playerItem.error as NSError? {
                        os_log("Failed to play HLS path (error code: %@)", log: OSLog.stormLibrary, type: .error, String(error.code))
                    }else{
                        os_log("Failed to play HLS path", log: OSLog.stormLibrary, type: .error)
                    }
                        
                    stormLibrary.dispatchEvent(.onVideoConnectionError, object: ConnectionError.hlsConnectionFailed("Failed to play HLS path"))
                default:
                    break;
            }
            
        }
        
        
        if keyPath == "rate", let player = object as? AVPlayer {
            if player.rate == 1 {
                stormLibrary.dispatchEvent(.onVideoPlay)
            } else {
                stormLibrary.dispatchEvent(.onVideoPause)
            }
        }
        
    
    }
    
}
