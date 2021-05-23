//
//  TimeDataPacket.swift
//  
//
//  Created by Sebastian Ceglarz on 22/05/2021.
//

public struct TimeDataPacket : Decodable{
    
    public struct TimeData : Decodable{
        
        public let sourceDuration : Int64
        public let dvrCacheSize : Int64
        public var streamDuration : Int64
        public let streamStartTime : Int64
        public let sourceStartTime : Int64

    }
    
    public let packetType : PacketType
    public var data : TimeData
    
}
