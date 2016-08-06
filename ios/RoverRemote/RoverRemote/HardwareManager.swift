//
//  HardwareManager.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 30/10/2015.
//  Copyright © 2015 Muhammed Miah. All rights reserved.
//

import Foundation
import UIKit

class HardwareManager : NSObject {
    
    // Hardware
    var hardwares : [String : Hardware] = [:]
    let restfulHardware = RestfulHardware()
    
    // Update values regularly
    var timer : NSTimer? = nil
    
    override init() {
        super.init()
        restfulHardware.addCallbackFunction(valueUpdateCallback)
        
        // Set up regular hardware updates
        self.setTimer()
    }
    
    func valueUpdateCallback(hardwareValues : [String : Double]) {
        // Update values in the hardware object
        for (hardware_name, hardware_value) in hardwareValues {
            if hardwares[hardware_name] == nil {
                hardwares[hardware_name] = Hardware(hardware_name: hardware_name, value: hardware_value)
                hardwares[hardware_name]!.restfulValueUpdateFunction = restfulHardware.setHardwareValue
            } else {
                hardwares[hardware_name]!.valueReturnedFromTheHardware(hardware_value)
            }
        }
        
        // Remove hardware object if underlying hardware no longer exists
        for (hardware_name, _) in hardwares {
            if hardwareValues[hardware_name] == nil {
                // hardware_name no longer exists on the actual hardware
                hardwares.removeValueForKey(hardware_name)
            }
        }
        
    }
    
    func clearAllHardware() {
        hardwares.removeAll(keepCapacity: true)
        removeTimer()
    }
    
    func moveForward() {
        print("Moving forward...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(100)
            rightMotor?.set(100)
        }
    }
    
    func moveBackward() {
        print("Reversing...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(-100)
            rightMotor?.set(-100)
        }
    }
    
    func rotateLeft() {
        print("Rotating left...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(-100)
            rightMotor?.set(100)
        }
    }
    
    func rotateRight() {
        print("Rotating right...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(100)
            rightMotor?.set(-100)
        }
    }
    
    func stop() {
        print("Stopping...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(0)
            rightMotor?.set(0)
        }
    }
    
    func moveNE() {
        print("Moving NE...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(100)
            rightMotor?.set(60)
        }
    }
    
    func moveNW() {
        print("Moving NW...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(60)
            rightMotor?.set(100)
        }
    }
    
    func moveSE() {
        print("Moving SE...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(-100)
            rightMotor?.set(-60)
        }
    }
    
    func moveSW() {
        print("Moving SW...")
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(-60)
            rightMotor?.set(-100)
        }
    }
    
    func moveAtAngleWithPower(angle : Double, power : Double) {
        // print("Angle:", angle*180.0/M_PI, "   Power:", power)
        var power = power
        
        var leftMotorPower = 0.0
        var rightMotorPower = 0.0
        
        if angle >= 0 {
            // Right half
            rightMotorPower = cos(abs(angle))
            if angle <= M_PI*0.5 {
                leftMotorPower = 1
            } else {
                leftMotorPower = -1 + 2*sin(abs(angle))
            }
        }
        if angle < 0 {
            // Left half
            leftMotorPower = cos(abs(angle))
            if angle >= M_PI * -0.5 {
                rightMotorPower = 1
            } else {
                rightMotorPower = -1 + 2*sin(abs(angle))
            }
        }
        
        // Normalize power
        let maxPower = max(abs(leftMotorPower), abs(rightMotorPower))
        leftMotorPower /= maxPower
        rightMotorPower /= maxPower
        
        // print("left:", leftMotorPower, "    right:", rightMotorPower)
        
        power += 0.5
        if power>1 {
            power = 1
        }
        leftMotorPower *= 100 * power
        rightMotorPower *= 100 * power
        
        let leftMotor = hardwares["motor-0"]
        let rightMotor = hardwares["motor-1"]
        if leftMotor != nil && rightMotor != nil {
            leftMotor?.set(Int32(leftMotorPower))
            rightMotor?.set(Int32(rightMotorPower))
        }
    }
    
    func updateAllHardwareValues() {
//        print("Updating all hardware values..")
        restfulHardware.updateHardwareList()
    }
    
    func timerFunc() {
        let currentTime = NSDate().timeIntervalSince1970
        
        let hardwareListUpdateDiff = currentTime - restfulHardware.hardwareListLastUpdateTime
        restfulHardware.handleInactiveHardwareListOngoingUpdateRequest()
        
        // Only update hardware list periodically
        if hardwareListUpdateDiff >= 3 && restfulHardware.hardwareListOngoingUpdateRequestTime == nil {
            updateAllHardwareValues()
        }
        
        // Set hardware values on the hardware as often as they change
        for (_, hardware) in hardwares {
            hardware.updateValueOnTheHardware()
        }
    }
    
    func setTimer() {
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(
                0.5,
                target: self,
                selector: #selector(timerFunc),
                userInfo: nil,
                repeats: true)
        }
    }
    
    func removeTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
}