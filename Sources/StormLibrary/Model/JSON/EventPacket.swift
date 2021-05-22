//
//  EventPacket.swift
//  
//
//  Created by Sebastian Ceglarz on 22/05/2021.
//

public struct EventPacket : Decodable{
    
    public struct Event : Decodable{
        
        let eventName : String

    }
    
    let packetType : PacketType
    let data : Event
    
}
