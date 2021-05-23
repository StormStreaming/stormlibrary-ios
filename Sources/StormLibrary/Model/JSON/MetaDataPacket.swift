//
//  MetaDataPacket.swift
//  
//
//  Created by Sebastian Ceglarz on 22/05/2021.
//

public struct MetaDataPacket : Decodable{
    
    public struct MetaData : Decodable{
        
        public let videoWidth : Int
        public let videoTimeScale : Int
        public let audioChannels : Int
        public let audioDataRate : Int
        public let variableFPS : Bool
        public let nominalFPS : Float
        public let audioCodec : String
        public let encoder : String
        public let audioSampleRate : Int
        public let audioSampleSize : Int
        public let videoHeight : Int
        public let videoCodec : String
    }
    
    public let packetType : PacketType
    public let data : MetaData
    
}
