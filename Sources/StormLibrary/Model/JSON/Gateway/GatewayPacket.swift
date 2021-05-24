//
//  GatewayPacket.swift
//  
//
//  Created by Sebastian Ceglarz on 24/05/2021.
//

public struct GatewayPacket : Decodable{
    
    
    public struct Server : Decodable{
        
        public let host : String
        public let port : Int
        public let isSSL : Bool
        
        enum CodingKeys: String, CodingKey {
            case host = "host"
            case port = "port"
            case isSSL = "ssl"
        }
    }
    
    public struct Source : Decodable{
        
        public let protocolName : String
        public let rtmpHost : String
        public let rtmpApplication : String
        public let application : String
        public let streamName : String
        public let streamInfo : StreamInfo
        public let isDefault : Bool?
        
        enum CodingKeys: String, CodingKey {
            case protocolName = "protocol"
            case rtmpHost = "rtmpHost"
            case application = "application"
            case rtmpApplication = "rtmpApplication"
            case streamName = "streamName"
            case streamInfo = "streamInfo"
            case isDefault = "isDefault"
        }
        
    }
    
    public struct StreamInfo : Decodable{
        
        public let label : String
        public let width : Int
        public let height : Int
        public let fps : Int
        public let bitrate : Int
    }
    
    public struct StreamData : Decodable{
        
        public let serverList : [Server]
        public let sourceList : [Source]
        

    }
    
    public let status : String
    public var stream : StreamData
    
}
