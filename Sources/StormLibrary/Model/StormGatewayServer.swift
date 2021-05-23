//
//  StormGatewayServer.swift
//  
//
//  Created by Sebastian Ceglarz on 23/05/2021.
//

public class StormGatewayServer : CustomStringConvertible{
    
    public let host : String
    public let applicationName : String
    public let port : Int
    public let isSSL : Bool
    
    public var connectionFailed = false
    
    public init(host : String, applicationName : String, port : Int, isSSL : Bool){
        self.host = host
        self.applicationName = applicationName
        self.port = port
        self.isSSL = isSSL
    }
    
    public var description: String {
        return "[host: \(host), port: \(port), isSSL: \(isSSL), applicationName: \(applicationName), connectionFailed: \(connectionFailed)]"
    }
    
    public func getWebSocketURL(groupName : String) -> String{
        return "\(isSSL ? "wss" : "ws")://\(host):\(port)/gateway/\(applicationName)/\(groupName)?encoding=text&"
    }
}
