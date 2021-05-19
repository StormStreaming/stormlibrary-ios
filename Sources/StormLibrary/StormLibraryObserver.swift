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

}

public extension StormLibraryObserver {
    func onVideoConnecting(){}
    func onVideoMetaData(videoMetaData : VideoMetaData){}
    func onVideoConnectionError(error : Error){}
    func onVideoPlay(){}
    func onVideoPause(){}
    func onVideoStop(){}
    func onVideoSeek(streamSeekUnixTime : UInt64){}
}


