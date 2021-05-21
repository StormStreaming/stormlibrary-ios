//
//  OSLogExt.swift
//  
//
//  Created by Sebastian Ceglarz on 21/05/2021.
//

import os.log
import SwiftUI

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like viewDidLoad.
    static let stormLibrary = OSLog(subsystem: subsystem, category: "StormLibrary")
}
