//
//  EventPacket.swift
//  
//
//  Created by Sebastian Ceglarz on 22/05/2021.
//

public struct EventPacket : Decodable{
    
    public struct Event : Decodable{
        
        public let eventName : String

    }
    
    public let packetType : PacketType
    public let data : Event
    
}
