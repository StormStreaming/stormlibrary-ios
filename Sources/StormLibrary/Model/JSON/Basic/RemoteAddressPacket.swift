//
//  RemoteAddressPacket.swift
//  
//
//  Created by Sebastian Ceglarz on 28/05/2021.
//

public struct RemoteAddressPacket : Decodable{
    
    public struct RemoteAddress : Decodable{
        
        public let streamURL : String
        
    }
    
    public let packetType : PacketType
    public let data : RemoteAddress
    
}
