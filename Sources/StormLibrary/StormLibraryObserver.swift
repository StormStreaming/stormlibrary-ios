//
//  StormLibraryObserver.swift
//  
//
//  Created by Sebastian Ceglarz on 19/05/2021.
//

public protocol StormLibraryObserver: AnyObject {
    func onVideoConnecting()
    func onVideoMetaData(videoMetaData : MetaDataPacket.MetaData)
    func onVideoProgress(videoTimeData : TimeDataPacket.TimeData)
    func onVideoConnectionError(error : Error)
    func onVideoPlay()
    func onVideoPause()
    func onVideoStop()
    func onVideoSeek(streamSeekUnixTime : Int64)
    func onIncompatiblePlayerProtocol()
    func onVideoNotFound()
    
    func onStormMediaItemAdded(stormMediaItem : StormMediaItem)
    func onStormMediaItemRemoved(stormMediaItem : StormMediaItem)
    func onStormMediaItemSelect(stormMediaItem : StormMediaItem)
    func onStormMediaItemPlay(stormMediaItem : StormMediaItem)
    
    func onGatewayConnecting()
    func onGatewayGroupNameNotFound()
    func onGatewayConnectionError(error : GatewayError)
    func onGatewayMediaItems(stormMediaItems: [StormMediaItem])
    
}

public extension StormLibraryObserver {
    func onVideoConnecting(){}
    func onVideoMetaData(videoMetaData : MetaDataPacket.MetaData){}
    func onVideoProgress(videoTimeData : TimeDataPacket.TimeData){}
    func onVideoConnectionError(error : Error){}
    func onVideoPlay(){}
    func onVideoPause(){}
    func onVideoStop(){}
    func onVideoSeek(streamSeekUnixTime : Int64){}
    func onIncompatiblePlayerProtocol(){}
    func onVideoNotFound(){}
    
    func onStormMediaItemAdded(stormMediaItem : StormMediaItem){}
    func onStormMediaItemRemoved(stormMediaItem : StormMediaItem){}
    func onStormMediaItemSelect(stormMediaItem : StormMediaItem){}
    func onStormMediaItemPlay(stormMediaItem : StormMediaItem){}
    
    func onGatewayConnecting(){}
    func onGatewayGroupNameNotFound(){}
    func onGatewayConnectionError(error : GatewayError){}
    func onGatewayMediaItems(stormMediaItems: [StormMediaItem]){}
}

public extension StormLibrary{
    enum EventType {
        case onVideoConnecting
        case onVideoMetaData
        case onVideoProgress
        case onVideoConnectionError
        case onVideoPlay
        case onVideoPause
        case onVideoStop
        case onVideoSeek
        case onStormMediaItemAdded
        case onStormMediaItemRemoved
        case onStormMediaItemSelect
        case onStormMediaItemPlay
        case onIncompatiblePlayerProtocol
        case onVideoNotFound
        case onGatewayConnecting
        case onGatewayGroupNameNotFound
        case onGatewayConnectionError
        case onGatewayMediaItems
        
    }
}
