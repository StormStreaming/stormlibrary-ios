//
//  StreamStatusPacket.swift
//  
//
//  Created by Sebastian Ceglarz on 22/05/2021.
//

public struct StreamStatusPacket : Decodable{
    
    public struct StreamStatus : Decodable{
        
        let streamState : String
        let streamName : String
        
    }
    
    let packetType : PacketType
    let data : StreamStatus
    
}
