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
    
    public static let PLAYER_PROTOCOL_VERSION = 1
    
    public var stormMediaItems : [StormMediaItem] = []
    
    public var streamStartTime : Int64 = 0
    public var streamDurationOffset : Int64 = 0
    public var lastPauseTime : Int64 = 0
    
    private var stormGateway : StormGateway?
    private var stormWebSocket : StormWebSocket!
    private var avPlayerObserver : AVPlayerObserver!
    private var observations = [ObjectIdentifier : Observation]()
    
    private let avPlayer : AVPlayer = AVPlayer()
   
    
    public init(){
        self.stormWebSocket = StormWebSocket(stormLibrary: self)
        self.avPlayerObserver = AVPlayerObserver(stormLibrary: self)
    }
    
    public func connectToGateway(groupName : String, stormGatewayServers : [StormGatewayServer], autoplay : Bool){
        if stormGateway == nil{
            stormGateway = StormGateway(stormLibrary: self)
        }

        stormGateway!.connect(groupName: groupName, stormGatewayServers: stormGatewayServers, autoplay: autoplay)
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
            
            os_log("Play", log: OSLog.stormLibrary, type: .info)
        }
    }
    
    public func pause(){
        avPlayer.pause()
        os_log("Pause", log: OSLog.stormLibrary, type: .info)
    }
    
    public func stop(){
        streamStartTime = 0
        streamDurationOffset = 0
        stormWebSocket.disconnect()
        avPlayer.replaceCurrentItem(with: nil)
        dispatchEvent(.onVideoPause)
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
    
    public func clearStormMediaItems(){
        
        for (_, item) in stormMediaItems.enumerated(){
            removeStormMediaItem(stormMediaItem: item)
        }
        
    }
    
    public func selectStormMediaItem(stormMediaItem : StormMediaItem, play : Bool = false, resetSeekPosition : Bool = true){
        stormWebSocket.disconnect()
        
        if resetSeekPosition{
            streamStartTime = 0;
            streamDurationOffset = 0;
        }
        
        for (_, item) in stormMediaItems.enumerated(){
            if item.isSelected{
                item.isSelected = false
            }
        }
        stormMediaItem.isSelected = true
        dispatchEvent(.onStormMediaItemSelect, object: stormMediaItem)
        os_log("Select StormMediaItem: %@", log: OSLog.stormLibrary, type: .info, stormMediaItem.description)
        
        if !play{
            stop()
        }else{
            stormWebSocket.connect(stormMediaItem: stormMediaItem, playAfterConnect: play)
        }
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
    
    public func setURLToAvPlayer(urlString: String){
        
        os_log("Connecting to HLS: %@", log: OSLog.stormLibrary, type: .info, urlString)
        
        let url = URL(string: urlString)
        let asset = AVAsset(url: url!)
        let playerItem = AVPlayerItem(asset: asset)
        
        avPlayer.replaceCurrentItem(with: playerItem)
        

        
    }
    
    public func seekTo(seekTime : Int64)throws {
        if(stormWebSocket.isConnected){
            stormWebSocket.disconnect()
            streamStartTime = 0
            streamDurationOffset = 0
            streamStartTime = seekTime
            try play()
            dispatchEvent(.onVideoSeek, object: seekTime)
            os_log("SeekTo: %@", log: OSLog.stormLibrary, type: .info, String(seekTime))
        }
    }
    
    public func dispatchEvent(_ eventType : EventType, object : Any? = nil){
        
        switch eventType {
            case .onVideoPlay:
                setStreamDurationOffset()
                break
            case .onVideoPause:
                setStreamDurationOffset()
                break
            default:
                break
        }
        
        for (id, observation) in observations {
            
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            switch eventType {
                case .onVideoMetaData:
                    observer.onVideoMetaData(videoMetaData: (object as? MetaDataPacket.MetaData)!)
                    break
                case .onVideoProgress:
                    observer.onVideoProgress(videoTimeData: (object as? TimeDataPacket.TimeData)!)
                    break
                case .onVideoPlay:
                    observer.onVideoPlay()
                    break
                case .onVideoPause:
                    observer.onVideoPause()
                    break
                case .onVideoStop:
                    observer.onVideoStop()
                    break
                case .onStormMediaItemAdded:
                    observer.onStormMediaItemAdded(stormMediaItem: (object as? StormMediaItem)!)
                    break
                case .onStormMediaItemRemoved:
                    observer.onStormMediaItemRemoved(stormMediaItem: (object as? StormMediaItem)!)
                    break
                case .onStormMediaItemSelect:
                    observer.onStormMediaItemSelect(stormMediaItem: (object as? StormMediaItem)!)
                    break
                case .onStormMediaItemPlay:
                    observer.onStormMediaItemPlay(stormMediaItem: (object as? StormMediaItem)!)
                    break
                case .onIncompatiblePlayerProtocol:
                    observer.onIncompatiblePlayerProtocol()
                    break
                case .onVideoNotFound:
                    observer.onVideoNotFound()
                    break;
                case .onGatewayGroupNameNotFound:
                    observer.onGatewayGroupNameNotFound()
                    break
                case .onGatewayConnectionError:
                    observer.onGatewayConnectionError(error: (object as? Error)!)
                    break
                case .onVideoConnectionError:
                    observer.onVideoConnectionError(error: (object as? Error)!)
                    break;
                case .onVideoConnecting:
                    observer.onVideoConnecting()
                    break;
                case .onVideoSeek:
                    observer.onVideoSeek(streamSeekUnixTime: (object as? Int64)!)
                    break;
                case .onGatewayConnecting:
                    observer.onGatewayConnecting()
                    break
                case .onGatewayMediaItems:
                    observer.onGatewayMediaItems(stormMediaItems: (object as? [StormMediaItem])!)
                    break
                    
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
    
    public func setStreamDurationOffset(){
        if !isPlaying(){
            lastPauseTime = Int64(Date().timeIntervalSince1970 * 1000)
        }else{
            if lastPauseTime != 0{
                streamDurationOffset += Int64(Date().timeIntervalSince1970 * 1000) - lastPauseTime
            }
            lastPauseTime = 0
        }
    }
    
}
