//
//  TimeDataPacket.swift
//  
//
//  Created by Sebastian Ceglarz on 22/05/2021.
//

public struct TimeDataPacket : Decodable{
    
    public struct TimeData : Decodable{
        
        let sourceDuration : Int
        let dvrCacheSize : Int
        let streamDuration : Int
        let streamStartTime : Int64
        let sourceStartTime : Int64

    }
    
    let packetType : PacketType
    let data : TimeData
    
}
