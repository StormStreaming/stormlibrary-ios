//
//  ServerData.swift
//  
//
//  Created by Sebastian Ceglarz on 22/05/2021.
//

public struct ServerDataPacket : Decodable{
    
    public struct ServerData : Decodable{
        
        let serverVersion : String
        let playerProtocol : Int
        let serverName : String
        
    }
    
    let packetType : PacketType
    let data : ServerData
    
}
