//
//  StormLibraryObserver.swift
//  
//
//  Created by Sebastian Ceglarz on 19/05/2021.
//

public protocol StormLibraryObserver: AnyObject {
    func onVideoConnecting()
    func onVideoMetaData(videoMetaData : VideoMetaData)
    func onVideoConnectionError(error : Error)
    func onVideoPlay()
    func onVideoPause()
    func onVideoStop()
    func onVideoSeek(streamSeekUnixTime : UInt64)
    
    func onStormMediaItemAdded(stormMediaItem : StormMediaItem)
    func onStormMediaItemRemoved(stormMediaItem : StormMediaItem)
    func onStormMediaItemSelect(stormMediaItem : StormMediaItem)
    func onStormMediaItemPlay(stormMediaItem : StormMediaItem)
    
}

public extension StormLibraryObserver {
    func onVideoConnecting(){}
    func onVideoMetaData(videoMetaData : VideoMetaData){}
    func onVideoConnectionError(error : Error){}
    func onVideoPlay(){}
    func onVideoPause(){}
    func onVideoStop(){}
    func onVideoSeek(streamSeekUnixTime : UInt64){}
    func onStormMediaItemAdded(stormMediaItem : StormMediaItem){}
    func onStormMediaItemRemoved(stormMediaItem : StormMediaItem){}
    func onStormMediaItemSelect(stormMediaItem : StormMediaItem){}
    func onStormMediaItemPlay(stormMediaItem : StormMediaItem){}
}

public extension StormLibrary{
    enum EventType {
        case onVideoConnecting
        case onVideoMetaData
        case onVideoConnectionError
        case onVideoPlay
        case onVideoPause
        case onVideoStop
        case onVideoSeek
        case onStormMediaItemAdded
        case onStormMediaItemRemoved
        case onStormMediaItemSelect
        case onStormMediaItemPlay
    }
}
