//
//  Config.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 06/08/2016.
//  Copyright © 2016 Muhammed Miah. All rights reserved.
//

import Foundation

class Config {
    
    static private let roverIPAddress = "192.168.1.82"
    
    static let restfulApiUrl = "https://" + roverIPAddress + "/"
    static let uv4lUrl = "http://" + roverIPAddress + ":8080/"
    
    
    
}
