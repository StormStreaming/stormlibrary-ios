//
//  StormLibrary.swift
//
//
//  Created by Sebastian Ceglarz on 17/05/2021.
//

import Foundation
import AVKit
import os.log

open class StormLibrary{
    
    public var stormMediaItems : [StormMediaItem] = []
    
    private var stormWebSocket : StormWebSocket!
    private var observations = [ObjectIdentifier : Observation]()
    
    //private let avPlayer : AVPlayer = AVPlayer(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
    
    private let avPlayer : AVPlayer = AVPlayer()

    public init(stormMediaItems : [StormMediaItem]) {
        self.stormWebSocket = StormWebSocket(stormLibrary: self)
        for(_, item) in stormMediaItems.enumerated(){
            addStormMediaItem(stormMediaItem: item)
        }
    }
    
    public func play() throws{
        
        guard let stormMediaItem = getSelectedStormMediaItem() else{
            throw SourceError.sourceNotSelectedError("No StormMediaItem was selected")
        }
        
        if !stormMediaItem.isConnectedToWebSocket{
            stormWebSocket.connect(stormMediaItem: stormMediaItem, playAfterConnect: true)
        }else{
            dispatchEvent(.onStormMediaItemPlay, object: stormMediaItem)
            avPlayer.play()
            dispatchEvent(.onVideoPlay)
            os_log("Play", log: OSLog.stormLibrary, type: .info)
        }
    }
    
    public func pause(){
        avPlayer.pause()
        dispatchEvent(.onVideoPause)
        os_log("Pause", log: OSLog.stormLibrary, type: .info)
    }
    
    public func stop(){
        stormWebSocket.disconnect()
        avPlayer.replaceCurrentItem(with: nil)
        dispatchEvent(.onVideoStop)
        os_log("Stop", log: OSLog.stormLibrary, type: .info)
    }
    
    public func addStormMediaItem(stormMediaItem: StormMediaItem){
        stormMediaItems.append(stormMediaItem)
        dispatchEvent(.onStormMediaItemAdded, object: stormMediaItem)
        os_log("Add StormMediaItem: %@", log: OSLog.stormLibrary, type: .info, stormMediaItem.description)
        if stormMediaItem.isSelected {
            selectStormMediaItem(stormMediaItem: stormMediaItem)
        }
    }
    
    public func removeStormMediaItem(stormMediaItem: StormMediaItem){

        if let index = stormMediaItems.firstIndex(where: {$0 === stormMediaItem}) {
            stormMediaItems.remove(at: index)
            dispatchEvent(.onStormMediaItemRemoved, object: stormMediaItem)
            os_log("Remove StormMediaItem: %@", log: OSLog.stormLibrary, type: .info, stormMediaItem.description)
        }
        if stormMediaItem.isConnectedToWebSocket{
            stormWebSocket.disconnect()
        }
 
    }
    
    public func selectStormMediaItem(stormMediaItem : StormMediaItem, play : Bool = false){
        stormWebSocket.disconnect()
        
        for (_, item) in stormMediaItems.enumerated(){
            if item.isSelected{
                item.isSelected = false
            }
        }
        stormMediaItem.isSelected = true
        dispatchEvent(.onStormMediaItemSelect, object: stormMediaItem)
        os_log("Select StormMediaItem: %@", log: OSLog.stormLibrary, type: .info, stormMediaItem.description)
        
        stormWebSocket.connect(stormMediaItem: stormMediaItem, playAfterConnect: play)
    }
    
    public func getSelectedStormMediaItem() -> StormMediaItem?{
        for (_, stormMediaItem) in stormMediaItems.enumerated(){
            if stormMediaItem.isSelected{
                return stormMediaItem
            }
        }
        return nil
    }
    
    public func isPlaying() -> Bool{
        return avPlayer.rate != 0 && avPlayer.error == nil
    }
    
    public func getAvPlayer() -> AVPlayer{
        return avPlayer;
    }
    
    public func setAvPlayerURL(urlString: String){
        let url = URL(string: urlString)
        let asset = AVAsset(url: url!)
        let playerItem = AVPlayerItem(asset: asset)
        
        avPlayer.replaceCurrentItem(with: playerItem)
    }
    
    public func dispatchEvent(_ eventType : EventType, object : Any? = nil){
        for (id, observation) in observations {
            
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            switch eventType {
                case .onVideoPlay:
                    observer.onVideoPlay()
                case .onVideoPause:
                    observer.onVideoPause()
                case .onVideoStop:
                    observer.onVideoStop()
                case .onStormMediaItemAdded:
                    observer.onStormMediaItemAdded(stormMediaItem: (object as? StormMediaItem)!)
                case .onStormMediaItemRemoved:
                    observer.onStormMediaItemRemoved(stormMediaItem: (object as? StormMediaItem)!)
                case .onStormMediaItemSelect:
                    observer.onStormMediaItemSelect(stormMediaItem: (object as? StormMediaItem)!)
                case .onStormMediaItemPlay:
                    observer.onStormMediaItemPlay(stormMediaItem: (object as? StormMediaItem)!)
                default:
                    break;
            }
        }
    }
    
    public func addObserver(_ observer: StormLibraryObserver){
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }
    
    public func removeObserver(_ observer: StormLibraryObserver){
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
    
    public struct Observation {
        weak var observer: StormLibraryObserver?
    }
    
    
}
