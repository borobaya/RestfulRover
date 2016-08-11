//
//  HardwareUIManager.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 03/08/2016.
//  Copyright © 2016 Muhammed Miah. All rights reserved.
//

import Foundation
import UIKit

class HardwareUIManager : NSObject {
    
    let hardwareManager = HardwareManager()
    
    // View
    var parent : UIView?
    
    // Control UI
    var controlWASD : ControlButtonsWASD?
    var controlJoystick : ControlJoystick?
    var controlSeparate : UIView?
    var controlSeparateList : [String : ControlHardware] = [:]
    
    // Camera
    var mjpegView : MjpegView?
    
    // Set up regular updates
    var timer : NSTimer? = nil
    
    override init() {
        super.init()
        hardwareManager.restfulHardware.addCallbackFunction(valueUpdateCallback)
    }
    
    func setup(parent : UIView) {
        self.parent = parent
        
        // Camera
        removeCamera()
        addCamera()
        
        // Set up regular hardware updates
        setTimer()
        
        hardwareManager.setup()
    }
    
    func valueUpdateCallback(hardwareValues : [String : Double]) {
        // Update UI values
        for (hardware_name, hardware_value) in hardwareValues {
            if controlSeparateList[hardware_name] != nil {
                let control = controlSeparateList[hardware_name]!
                dispatch_async(dispatch_get_main_queue(), {
                    control.valueWasUpdated(Int32(hardware_value))
                })
            }
        }
        
        // Remove UI controls if underlying hardware no longer exists
        for (hardware_name, _) in controlSeparateList {
            if hardwareValues.count > 1 && hardwareValues[hardware_name] == nil {
                // hardware_name no longer exists on the actual hardware
                controlSeparateList = ControlHardware.removeSingleUIControl(controlSeparateList, hardware_name: hardware_name)
                
                if controlSeparateList.count == 0 {
                    (controlSeparate, controlSeparateList) =  ControlHardware.removeAllUIControls(
                        controlSeparate, controlSeparateList: controlSeparateList)
                }
            }
        }
    }

    
    func updateUI() {
        if parent==nil {
            return
        }
        
//        (controlSeparate, controlSeparateList) = ControlHardware.updateUI(hardwareManager,
//                                                                          controlSeparate: controlSeparate,
//                                                                          controlSeparateList: controlSeparateList,
//                                                                          containerView: parent!)
        
        controlWASD = ControlButtonsWASD.updateUI(hardwareManager, controlWASD: controlWASD, containerView: parent!)
        controlJoystick = ControlJoystick.updateUI(hardwareManager, controlJoystick: controlJoystick, containerView: parent!)
    }
    
    func repositionUI() {
        ControlHardware.repositionUI(controlSeparate)
        ControlButtonsWASD.repositionUI(controlWASD)
        ControlJoystick.repositionUI(controlJoystick)
    }
    
    func removeUI() {
        removeTimer()
        removeCamera()
        hardwareManager.reset()
        
        (controlSeparate, controlSeparateList) =  ControlHardware.removeAllUIControls(
            controlSeparate, controlSeparateList: controlSeparateList)
        
        controlWASD?.removeFromSuperview()
        controlWASD = nil
        
        controlJoystick?.removeFromSuperview()
        controlJoystick = nil
    }
    
    
    func timerFunc() {
        updateUI()
    }
    
    func setTimer() {
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(
                0.3,
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
    
    
    func addCamera() {
        // Show camera
        if mjpegView == nil && parent != nil {
            mjpegView = MjpegView(frame: CGRect(x: 0, y: 80, width: parent!.frame.width, height: parent!.frame.width * 2/3))
            mjpegView!.start()
            parent!.addSubview(mjpegView!)
        }
    }
    
    func removeCamera() {
        // Stop camera if it's ON
        if mjpegView != nil {
            mjpegView!.stop()
            if mjpegView!.superview != nil {
                mjpegView!.removeFromSuperview()
            }
            mjpegView = nil
        }
    }
    
}
