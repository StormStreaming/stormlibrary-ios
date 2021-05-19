//
//  StormLibrary.swift
//
//
//  Created by Sebastian Ceglarz on 17/05/2021.
//

import Foundation
import AVKit

open class StormLibrary : ObservableObject{
    
    private var sources : [StormSource] = []
    private var selectedSource : StormSource?
    private var stormWebSocket : StormWebSocket = StormWebSocket()
    private var observations = [ObjectIdentifier : Observation]()
    
    public let avPlayer : AVPlayer = AVPlayer(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
    
    public var isPlaying: Bool {
            return avPlayer.rate != 0 && avPlayer.error == nil
        }

    
    public init(sources : [StormSource]) {
        self.sources = sources
    }
    
    public func play() throws{
        
        guard let source = selectedSource else{
            throw SourceError.sourceNotSelectedError("No source was selected")
        }
        
        if !stormWebSocket.isConnected{
            stormWebSocket.connect(source: source, playAfterConnect: true)
        }else{
            avPlayer.play()
            dispatchEvent(.onVideoPlay)
        }
    }
    
    public func pause(){
        avPlayer.pause()
        dispatchEvent(.onVideoPause)
    }
    
    public func stop(){
        stormWebSocket.disconnect()
        avPlayer.replaceCurrentItem(with: nil)
        dispatchEvent(.onVideoStop)
    }
    
    public func selectSource(source : StormSource, play : Bool = false){
        stormWebSocket.disconnect()
        selectedSource = source
        stormWebSocket.connect(source: selectedSource!, playAfterConnect: play)
    }
    
    public func prepare() throws{
        if sources.count == 0{
            throw SourceError.sourceListIsEmptyError("Source list is empty")
        }
        
        var defaultSource : StormSource?
        
        for source in sources{
            
            if(source.isDefault){
                defaultSource = source
                break
            }
            
        }
        
        if defaultSource == nil{
            defaultSource = sources[0]
        }
        
        selectSource(source: defaultSource!)
        
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
