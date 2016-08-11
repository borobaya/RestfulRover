//
//  Config.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 06/08/2016.
//  Copyright © 2016 Muhammed Miah. All rights reserved.
//

import Foundation

class Config {
    
    static private var roverIPAddress = "" //Config.updateRoverIPAddress("192.168.1.82")
    
    static var restfulApiUrl = ""
    static var uv4lUrl = ""
    
    static func updateRoverIPAddress(address : String) -> String {
        self.roverIPAddress = address
        self.restfulApiUrl = "https://" + roverIPAddress + "/hardware/"
        self.uv4lUrl = "http://" + roverIPAddress + ":8080/"
        return address
    }

}
