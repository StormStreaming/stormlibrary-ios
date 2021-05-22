//
//  MetaDataPacket.swift
//  
//
//  Created by Sebastian Ceglarz on 22/05/2021.
//

public struct MetaDataPacket : Decodable{
    
    public struct MetaData : Decodable{
        
        let videoWidth : Int
        let videoTimeScale : Int
        let audioChannels : Int
        let audioDataRate : Int
        let variableFPS : Bool
        let nominalFPS : Float
        let audioCodec : String
        let encoder : String
        let audioSampleRate : Int
        let audioSampleSize : Int
        let videoHeight : Int
        let videoCodec : String
    }
    
    let packetType : PacketType
    let data : MetaData
    
}
