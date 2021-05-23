//
//  PacketType.swift
//
//
//  Created by Sebastian Ceglarz on 22/05/2021.
//

public enum PacketType : String, Decodable{

    case serverData, streamStatus, metaData, timeData, event
}
