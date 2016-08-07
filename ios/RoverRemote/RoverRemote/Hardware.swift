//
//  Hardware.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 29/10/2015.
//  Copyright © 2015 Muhammed Miah. All rights reserved.
//

import Foundation

class Hardware : NSObject {
    
    let hardware_name : String
    var actual_value : Int32 = 0
    var target_value : Int32 = 0
    var last_sent_value : Int32 = 0
    
    let hardware_type : String
    let value_type : String
    
    var restfulValueUpdateFunction : Optional<(String, Double) -> Void>
//    var notify : [(Int32) -> Void] = []
    
    init(hardware_name : String) { // , restfulValueUpdateFunction : (String, Double) -> Void
        self.hardware_name = hardware_name
        self.hardware_type = self.hardware_name.componentsSeparatedByString("-").first!
        
        switch self.hardware_type {
        case "motor":
            self.value_type = "continuous"
        case "led":
            self.value_type = "binary"
        case "battery":
            self.value_type = "continuous"
        case "infrared":
            self.value_type = "continuous"
        default:
            self.value_type = "continuous"
        }
    }
    
    convenience init(hardware_name : String, value : Double) {
        self.init(hardware_name : hardware_name)
        self.target_value = Int32(value)
        self.actual_value = Int32(value)
        
//        print("New hardware object created: " + hardware_name + " with the initial value " + String(self.target_value))
    }
    
    func set(value : Int32) {
        target_value = value
        if hardware_type == "motor" && abs(target_value)<30 {
            target_value = 0
        } else if hardware_type != "binary" && abs(target_value)<10 {
            target_value = 0
        }
        updateValueOnTheHardware()
    }
    
    func get() -> Int32 {
        return self.actual_value
    }
    
    func updateValueOnTheHardware() {
        if target_value==actual_value && target_value==last_sent_value {
            return
        }
        
        if value_type != "binary" {
            // Stops sending too many messages, i.e. when user has finger continually pressed on control
            if abs(target_value-last_sent_value) < 5 {
                return
            }
        }
        
//        print("Changing", hardware_name, "value from", actual_value, "to", target_value)
        
        // Send write signal
        if restfulValueUpdateFunction != nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.restfulValueUpdateFunction!(self.hardware_name, Double(self.target_value))
                self.last_sent_value = self.target_value
            })
        }
    }
    
    func valueReturnedFromTheHardware(value : Double) {
        self.actual_value = Int32(value)
//        notifyFuncs()
        
//        print("Value returned for hardware", hardware_name, "of", self.actual_value)
    }
    
//    func addNotifyFunc(f : (Int32) -> Void) {
//        notify.append(f)
//    }
//    
//    func notifyFuncs() {
//        let value = get()
//        for f in notify {
//            f(value)
//        }
//    }
    
}
