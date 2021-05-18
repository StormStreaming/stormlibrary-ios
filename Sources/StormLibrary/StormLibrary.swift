//
//  StormLibrary.swift
//
//
//  Created by Sebastian Ceglarz on 17/05/2021.
//

import Foundation
import AVKit

open class StormLibrary{
     
    private var config : StormConfig
    private var selectedSource : StormSource?
    private var stormWebSocket : StormWebSocket = StormWebSocket()
    
    public init(config : StormConfig) {
        self.config = config
    }
    
    public let avPlayer : AVPlayer = AVPlayer(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
    
    public var isPlaying: Bool {
        return avPlayer.rate != 0 && avPlayer.error == nil
    }
    
    public func play() throws{
        
        guard let source = selectedSource else{
            throw SourceError.sourceNotSelectedError("No source was selected")
        }
        
        if !stormWebSocket.isConnected{
            stormWebSocket.connect(source: source, playAfterConnect: true)
        }else{
            avPlayer.play()
        }
    }
    
    public func pause(){
        avPlayer.pause()
    }
    
    public func stop(){
        stormWebSocket.disconnect()
        avPlayer.replaceCurrentItem(with: nil)
    }
    
    public func selectSource(source : StormSource, play : Bool = false){
        stormWebSocket.disconnect()
        selectedSource = source
        stormWebSocket.connect(source: selectedSource!, playAfterConnect: play)
    }
    
    public func prepare() throws{
        if config.sources.count == 0{
            throw SourceError.sourceListIsEmptyError("Source list is empty")
        }
        
        var defaultSource : StormSource?
        
        for source in config.sources{
            
            if(source.isDefault){
                defaultSource = source
                break
            }
            
        }
        
        if defaultSource == nil{
            defaultSource = config.sources[0]
        }
        
        selectSource(source: defaultSource!, play: config.autostart)
        
    }
    
}
