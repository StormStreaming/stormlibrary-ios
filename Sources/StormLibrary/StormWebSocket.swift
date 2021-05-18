//
//  StormWebSocket.swift
//  
//
//  Created by Sebastian Ceglarz on 17/05/2021.
//

import SwiftUI
import Starscream
import os.log


public class StormWebSocket: WebSocketDelegate{
    
    public var isConnected : Bool = false
    public var socket : WebSocket!
    
    public func connect(source: StormSource, playAfterConnect : Bool = false){
        disconnect()


        var request = URLRequest(url: URL(string: "wss://stormdev.web-anatomy.com:443/storm/stream/?url=rtmp%3A%2F%2Fstormdev.web-anatomy.com%3A1935%2Flive&stream=test_hd&")!) //https://localhost:8080
        

        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
    }
    
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
            switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
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
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error?) {
            if let e = error as? WSError {
                if #available(iOS 14.0, *) {
                    os_log("StormLibrary error: websocket encountered an error: \(e.message)")
                } else {
                    os_log("StormLibrary error: websocket encountered an error")
                }
            } else if let e = error {
                if #available(iOS 14.0, *) {
                    os_log("StormLibrary error: websocket encountered an error: \(e.localizedDescription)")
                } else {
                    os_log("StormLibrary error: websocket encountered an error")
                }
            } else {
                os_log("StormLibrary error: websocket encountered an error")
            }
        }
    
    public func disconnect(){
        if socket != nil{
            socket.disconnect()
        }
    }
    
}
