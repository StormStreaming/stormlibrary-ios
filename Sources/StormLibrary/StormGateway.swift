//
//  StormGateway.swift
//  
//
//  Created by Sebastian Ceglarz on 23/05/2021.
//

import SwiftUI
import Starscream
import os.log

public class StormGateway : WebSocketDelegate{
    
    private let stormLibrary : StormLibrary
    
    private var groupName : String!
    private var stormGatewayServers : [StormGatewayServer]!
    private var playAfterConnect = false
    
    public var isConnected : Bool = false
    public var socket : WebSocket!
    public var currentStormGatewayServer : StormGatewayServer?
    
    public init(stormLibrary : StormLibrary){
        self.stormLibrary = stormLibrary
    }
    
    public func connect(groupName : String, stormGatewayServers : [StormGatewayServer], autoplay : Bool) {
        stormLibrary.clearStormMediaItems()
        self.stormGatewayServers = stormGatewayServers
        self.groupName = groupName
        self.playAfterConnect = autoplay
        connect()
    }
    
    private func reconnect(){
        if let currentGatewayServer = currentStormGatewayServer{
            currentGatewayServer.connectionFailed = true
        }
        connect()
    }
    
    private func connect() {
       
        disconnect()
        currentStormGatewayServer = getNextServerToConnect()
        if currentStormGatewayServer == nil{
            stormLibrary.dispatchEvent(.onGatewayConnectionError, object: GatewayError.connectionFailed("Gateway WebSocket: Could not connect to any servers on the gateway server list"))
            os_log("Gateway WebSocket: Could not connect to any servers on the gateway server list", log: OSLog.stormLibrary, type: .error)
            return;
        }
        
        
        var request = URLRequest(url: URL(string: currentStormGatewayServer!.getWebSocketURL(groupName: groupName))!) //https://localhost:8080
        
        stormLibrary.dispatchEvent(.onGatewayConnecting)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
        os_log("Gateway WebSocket is connecting to: %@", log: OSLog.stormLibrary, type: .info, currentStormGatewayServer!.getWebSocketURL(groupName: groupName))
        
    }
    
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
            switch event {
        case .connected(let headers):
            isConnected = true

            os_log("Gateway WebSocket is connected", log: OSLog.stormLibrary, type: .info)
            
        case .disconnected(let reason, let code):
            isConnected = false
            if let currentGateway = currentStormGatewayServer{
                currentGateway.connectionFailed = true
            }
            os_log("Gateway WebSocket disconnected: %@ %@", log: OSLog.stormLibrary, type: .info, reason, code)
        case .text(let string):
            //print("Received text: \(string)")
            parseMessage(message: string)
            break
        case .binary(let data):
            //print("Received data: \(data.count)")
            break
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
            if let currentGateway = currentStormGatewayServer{
                currentGateway.connectionFailed = true
            }
            os_log("WebSocket disconnected: cancelled", log: OSLog.stormLibrary, type: .info)
        case .error(let error):
            isConnected = false
            if let currentGateway = currentStormGatewayServer{
                currentGateway.connectionFailed = true
            }
            handleError(error)
        }
        
    }
    
    private func parseMessage(message : String){
        
        let message2 = "{\"status\":\"success\",\"stream\":{\"serverList\":[{\"host\":\"stormdev.web-anatomy.com\",\"application\":\"live\",\"port\":443,\"ssl\":true}],\"sourceList\":[{\"protocol\":\"rtmp\", \"host\":\"stormdev.web-anatomy.com\", \"application\":\"live\",\"streamName\":\"test_lq\",\"application\":\"live\",\"streamInfo\":{\"label\":\"360p\",\"width\":640,\"height\":360,\"fps\":30,\"bitrate\":2500}},{\"protocol\":\"rtmp\", \"host\":\"stormdev.web-anatomy.com\", \"application\":\"live\", \"streamName\":\"test_sd\",\"application\":\"live\",\"isDefault\":true,\"streamInfo\":{\"label\":\"720p\",\"width\":1280,\"height\":720,\"fps\":30,\"bitrate\":5000}},{\"protocol\":\"rtmp\",\"host\":\"stormdev.web-anatomy.com\", \"application\":\"live\",\"streamName\":\"test_hd\",\"application\":\"live\",\"streamInfo\":{\"label\":\"1080p\",\"width\":1920,\"height\":1080,\"fps\":30,\"bitrate\":7000}}]}}"
  
        
        
        let jsonData = message2.data(using: .utf8)!
        do{
            let gatewayPacket = try JSONDecoder().decode(GatewayPacket.self, from: jsonData)
            
            if gatewayPacket.status == "success"{
            
                var stormMediaItems : [StormMediaItem] = []
                
                for (_, source) in gatewayPacket.stream.sourceList.enumerated(){
                    
                    var stormMediaItem : StormMediaItem?
                 
                    if source.protocolName == "rtmp"{
                        stormMediaItem = StormMediaItem(host: gatewayPacket.stream.serverList[0].host, port: gatewayPacket.stream.serverList[0].port, isSSL: gatewayPacket.stream.serverList[0].isSSL, applicationName: source.application, streamName: source.streamName, label: source.streamInfo.label, rtmpHost: source.host, rtmpApplicationName: source.application, isSelected: source.isDefault != nil ? source.isDefault! : false)
                    }else{
                        stormMediaItem = StormMediaItem(host: gatewayPacket.stream.serverList[0].host, port: gatewayPacket.stream.serverList[0].port, isSSL: gatewayPacket.stream.serverList[0].isSSL, applicationName: source.application, streamName: source.streamName, label: source.streamInfo.label, isSelected: source.isDefault != nil ? source.isDefault! : false)
                    }
                    
                    stormMediaItems.append(stormMediaItem!)
                    stormLibrary.addStormMediaItem(stormMediaItem: stormMediaItem!)
                }
                
                stormLibrary.dispatchEvent(.onGatewayMediaItems, object:stormMediaItems)
                
            }else{
                os_log("Given groupName was not found", log: OSLog.stormLibrary, type: .error)
                stormLibrary.dispatchEvent(.onGatewayGroupNameNotFound)
            }
            
            if playAfterConnect{
                do{
                    try stormLibrary.play()
                } catch let error {
                    os_log("Play error: %@", log: .stormLibrary, type: .error, String(describing: error))
                }
            }else{
                stormLibrary.pause()
            }
            
        }catch{
            os_log("Gateway WebSocket parse message error: %@", log: OSLog.stormLibrary, type: .error, error.localizedDescription)
        }
        disconnect()
    }
    
    public func disconnect(){
        if socket != nil{
            socket.disconnect()
            currentStormGatewayServer = nil
            os_log("Gateway WebSocket disconnected", log: OSLog.stormLibrary, type: .info)
        }
        isConnected = false
    }
    
    private func getNextServerToConnect() -> StormGatewayServer?{
        for (_, gatewayServer) in stormGatewayServers.enumerated(){
            if !gatewayServer.connectionFailed{
                return gatewayServer
            }
        }
        return nil;
    }
    
    private func handleError(_ error: Error?) {
        stormLibrary.dispatchEvent(.onGatewayConnectionError, object: error)
        if let currentGateway = currentStormGatewayServer{
            currentGateway.connectionFailed = true
        }
        if let e = error as? WSError {
            os_log("Gateway WebSocket encountered an error: %@", log: OSLog.stormLibrary, type: .error, e.message)
        } else if let e = error {
                os_log("Gateway WebSocket encountered an error: %@", log: OSLog.stormLibrary, type: .error, e.localizedDescription)
        } else {
            os_log("Gateway WebSocket encountered an error", log: OSLog.stormLibrary, type: .error)
        }
        reconnect()
    }
    
}
