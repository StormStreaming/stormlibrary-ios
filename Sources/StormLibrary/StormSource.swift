//
//  StormConfig.swift
//  
//
//  Created by Sebastian Ceglarz on 17/05/2021.
//

import SwiftUI


public struct StormSource{
    
    public var host : String
    public var port : Int
    public var isSSL : Bool
    public var streamName : String
    public var label : String
    
    public var isDefault : Bool = false
    
    public init(host : String, port : Int, isSSL : Bool, streamName : String, label : String){
        self.host = host
        self.port = port
        self.isSSL = isSSL
        self.streamName = streamName
        self.label = label
    }
    
}
