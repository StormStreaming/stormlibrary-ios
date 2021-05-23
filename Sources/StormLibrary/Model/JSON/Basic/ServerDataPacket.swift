//
//  ServerData.swift
//  
//
//  Created by Sebastian Ceglarz on 22/05/2021.
//

public struct ServerDataPacket : Decodable{
    
    public struct ServerData : Decodable{
        
        public let serverVersion : String
        public let playerProtocol : Int
        public let serverName : String
        
    }
    
    public let packetType : PacketType
    public let data : ServerData
    
}
