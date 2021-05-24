//
//  AVPlayerView.swift
//
//  Created by Sebastian Ceglarz on 10/05/2021.
//

import SwiftUI
import AVKit

public struct AVPlayerView: UIViewControllerRepresentable {
    
    public var player : AVPlayer
    
    public init(player : AVPlayer){
        self.player = player
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<AVPlayerView>) -> AVPlayerViewController{
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller;
    }
    
    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}
