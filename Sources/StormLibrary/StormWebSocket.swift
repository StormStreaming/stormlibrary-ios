//
//  StormWebSocket.swift
//  
//
//  Created by Sebastian Ceglarz on 17/05/2021.
//

import SwiftUI
import Starscream
import os.log

public class StormWebSocket : WebSocketDelegate{
    
    public var isConnected : Bool = false
    public var socket : WebSocket!
    public var stormMediaItem : StormMediaItem!
    
    private var playAfterConnect = false
    private var stormLibrary : StormLibrary
    
    public init(stormLibrary : StormLibrary){
        self.stormLibrary = stormLibrary
    }
    
    public func connect(stormMediaItem: StormMediaItem, playAfterConnect : Bool = false){
        self.stormMediaItem = stormMediaItem
        self.playAfterConnect = playAfterConnect
        disconnect()

        
        /*
         url += "seekStart="+this.stormLibrary.getStreamStartTime()+"&";
         */
        var request = URLRequest(url: URL(string: "wss://stormdev.web-anatomy.com:443/storm/stream/?url=rtmp%3A%2F%2Fstormdev.web-anatomy.com%3A1935%2Flive&stream=test_hd&seekStart=\(stormLibrary.streamStartTime)&")!) //https://localhost:8080
        
        stormLibrary.dispatchEvent(.onVideoConnecting)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
        os_log("WebSocket is connecting to: %@", log: OSLog.stormLibrary, type: .info, stormMediaItem.getWebSocketURL())
        
    }
    
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
            switch event {
        case .connected(let headers):
            isConnected = true
            stormMediaItem.isConnectedToWebSocket = true
            os_log("WebSocket is connected", log: OSLog.stormLibrary, type: .info)
            
            stormLibrary.setURLToAvPlayer(urlString: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
            
            
            if playAfterConnect{
                do{
                    try stormLibrary.play()
                } catch let error {
                    os_log("Play error: %@", log: OSLog.stormLibrary, type: .error, String(describing: error))
                }
            }
            
        case .disconnected(let reason, let code):
            isConnected = false
            stormMediaItem.isConnectedToWebSocket = false
            os_log("WebSocket disconnected: %@ %@", log: OSLog.stormLibrary, type: .info, reason, code)
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
            stormMediaItem.isConnectedToWebSocket = false
            os_log("WebSocket disconnected: cancelled", log: OSLog.stormLibrary, type: .info)
        case .error(let error):
            handleError(error)
            isConnected = false
            stormMediaItem.isConnectedToWebSocket = false
        }
    }
    
    private func parseMessage(message : String){
        
        let jsonData = message.data(using: .utf8)!
    
        
        do{
            let packetTypePacket = try JSONDecoder().decode(PacketTypePacket.self, from: jsonData)
        
            switch packetTypePacket.packetType{
                case .serverData:
                    let serverDataPacket = try JSONDecoder().decode(ServerDataPacket.self, from: jsonData)
                    
                    os_log("Storm Server: %@ | Version: %@ | PlayerProtocolVersion: %@ | ServerProtocolVersion: %@", log: OSLog.stormLibrary, type: .info, serverDataPacket.data.serverName,
                           serverDataPacket.data.serverVersion, String(StormLibrary.PLAYER_PROTOCOL_VERSION), String(serverDataPacket.data.playerProtocol))
                    
                    if serverDataPacket.data.playerProtocol != StormLibrary.PLAYER_PROTOCOL_VERSION{
                        stormLibrary.dispatchEvent(.onIncompatiblePlayerProtocol)
                    }
                    break;
                case .streamStatus:
                    //let streamStatusPacket = try! JSONDecoder().decode(StreamStatusPacket.self, from: jsonData)
                
                    
                    break;
                case .metaData:
                    let metaDataPacket = try JSONDecoder().decode(MetaDataPacket.self, from: jsonData)
                    
                    stormLibrary.dispatchEvent(.onVideoMetaData, object: metaDataPacket.data)
                
                case .timeData:
                    var timeDataPacket = try JSONDecoder().decode(TimeDataPacket.self, from: jsonData)
                    
                    let realTimeOffset = stormLibrary.lastPauseTime != 0 ? Int64(Date().timeIntervalSince1970 * 1000)-stormLibrary.lastPauseTime : 0
                    
                    timeDataPacket.data.streamDuration = timeDataPacket.data.streamDuration - realTimeOffset
                
                    stormLibrary.streamStartTime = timeDataPacket.data.streamStartTime + timeDataPacket.data.streamDuration
                    stormLibrary.dispatchEvent(.onVideoProgress, object: timeDataPacket.data)
                case .event:
                    let eventPacket = try! JSONDecoder().decode(EventPacket.self, from: jsonData)
                
                    switch eventPacket.data.eventName{
                        case "StreamNotFound":
                            stormLibrary.dispatchEvent(.onVideoNotFound)
                            disconnect()
                            break;
                        case "StreamUnpublished":
                            stormLibrary.dispatchEvent(.onVideoStop)
                            disconnect()
                            break;
                        case "newVideo":
                            break;
                        default:
                            break;
                    }
                    break;
            }
        
        }catch{
            os_log("WebSocket parse message error: %@", log: OSLog.stormLibrary, type: .error, error.localizedDescription)
        }
    }
    
    private func handleError(_ error: Error?) {
        if !isConnected{
            return
        }
        stormLibrary.dispatchEvent(.onVideoConnectionError, object: error)
        stormMediaItem.isConnectedToWebSocket = false
            if let e = error as? WSError {
                os_log("WebSocket encountered an error: %@", log: OSLog.stormLibrary, type: .error, e.message)
            } else if let e = error {
                    os_log("WebSocket encountered an error: %@", log: OSLog.stormLibrary, type: .error, e.localizedDescription)
            } else {
                os_log("WebSocket encountered an error", log: OSLog.stormLibrary, type: .error)
            }
        }
    
    public func disconnect(){
        isConnected = false
        if socket != nil{
            socket.disconnect()
            stormMediaItem.isConnectedToWebSocket = false
            os_log("WebSocket disconnected", log: OSLog.stormLibrary, type: .info)
        }
        
    }
    
}
