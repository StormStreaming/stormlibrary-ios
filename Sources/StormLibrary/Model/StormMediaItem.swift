//
//  StormMediaItem.swift
//  
//
//  Created by Sebastian Ceglarz on 17/05/2021.
//

import SwiftUI


public class StormMediaItem : CustomStringConvertible{
    
    public var host : String
    public var port : Int
    public var isSSL : Bool
    public var streamName : String
    public var applicationName : String
    public var label : String
    
    public var rtmpHost : String?
    public var rtmpApplicationName : String?
    
    public var isSelected : Bool = false
    
    public var isConnectedToWebSocket = false
    
    public init(host : String, port : Int, isSSL : Bool, applicationName: String, streamName : String, label : String, isSelected : Bool = false){
        self.host = host
        self.port = port
        self.isSSL = isSSL
        self.streamName = streamName
        self.applicationName = applicationName
        self.label = label
        self.isSelected = isSelected
    }
    
    public convenience init(host : String, port : Int, isSSL : Bool, applicationName: String, streamName : String, label : String, rtmpHost : String, rtmpApplicationName : String, isSelected : Bool = false){
        self.init(host: host, port: port, isSSL: isSSL, applicationName: applicationName, streamName: streamName, label: label, isSelected: isSelected)
        self.rtmpHost = rtmpHost
        self.rtmpApplicationName = rtmpApplicationName
    }
    
    public var description: String {
        return "[host: \(host), port: \(port), isSSL: \(isSSL), streamName: \(streamName), applicationName: \(applicationName), label: \(label), rtmpHost: \(String(describing: rtmpHost)), rtmpApplicationName: \(String(describing:rtmpApplicationName)), isSelected: \(isSelected), isConnectedToWebSocket: \(isConnectedToWebSocket)"
        
    }
    
    public func getWebSocketURL() -> String{
        return "https://asdasd"
    }
    
    
}
