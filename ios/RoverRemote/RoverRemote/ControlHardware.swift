//
//  ControlHardware.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 01/11/2015.
//  Copyright © 2015 Muhammed Miah. All rights reserved.
//

import UIKit

class ControlHardware : UIView {
    
    var hardware : Hardware!
    var label = UILabel()
    var control : UIView! // Make sure this is assigned in setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(hardware : Hardware, frame : CGRect) {
        self.hardware = hardware
        let width = min(frame.width, frame.height)
        
        label.text = hardware.hardware_name + ":"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        label.sizeToFit()
        label.frame = CGRect(x: 0, y: 0, width: label.bounds.width, height: label.bounds.height)
        self.addSubview(label)
        
        if hardware.hardware_type=="motor" {
            let slider = UISlider()
            slider.tag = 1
            slider.minimumValue = -100
            slider.maximumValue = 100
            slider.value = Float(hardware.get())
            slider.continuous = false
            slider.frame = CGRect(x: 0, y: 0, width: width*0.5, height: 30)
            slider.addTarget(self, action: #selector(ControlHardware.sliderChanged(_:)), forControlEvents: .AllEvents)
            control = slider
        } else if hardware.value_type=="binary" {
            let button = UISwitch()
            button.setOn(hardware.get() != 0, animated: false)
            button.sizeToFit()
            button.addTarget(self, action: #selector(ControlHardware.toggled(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            control = button
        } else if hardware.value_type=="continuous" {
            let value = UILabel()
            value.text = String(hardware.get())
            value.font = UIFont(name: "HelveticaNeue-Light", size: 18)
            value.sizeToFit()
            control = value
        } else {
            control = UIControl()
        }
        
        control.frame = CGRect(x: label.bounds.width+10, y: 0, width: control.bounds.width, height: control.bounds.height)
        self.addSubview(control)
        
        // Vertically align the elements
        let maxY = max(label.frame.maxY, control.frame.maxY)
        label.center = CGPoint(x: label.center.x, y: maxY/2)
        control.center = CGPoint(x: control.center.x, y: maxY/2)
        
        self.frame = CGRect(x: 0, y: 0,
                            width: control.frame.maxX - label.frame.minX,
                            height: control.frame.maxY - control.frame.minY)
    }
    
    // Callback on value update
    func valueWasUpdated(newValue : Int32) {
        if hardware.hardware_type=="motor" {
            let slider = control as! UISlider
            slider.value = Float(newValue)
        } else if hardware.value_type=="binary" {
            let button = control as! UISwitch
            button.setOn(newValue != 0, animated: true)
        } else if hardware.value_type=="continuous" {
            let value = control as! UILabel
            value.text = String(newValue)
        } else {
        }
    }
    
    // Controls touched
    func sliderChanged(sender : UISlider) {
        if (hardware != nil) {
            let value = Int32(sender.value)
            hardware!.set(value)
        }
    }
    
    func toggled(sender : UISwitch) {
        if hardware == nil {
            return
        }
        
        hardware!.set(sender.on ? 1 : 0)
    }
    
    static func updateUI(hardwareManager : HardwareManager,
                         controlSeparate : UIView?,
                         controlSeparateList : [String : ControlHardware],
                         containerView : UIView) -> (UIView?, [String : ControlHardware]) {
        var controlSeparate = controlSeparate
        var controlSeparateList = controlSeparateList
        
        if controlSeparate == nil {
            controlSeparate = UIView()
            controlSeparate!.frame.origin = CGPoint(x:containerView.frame.width*0.2, y: 110)
            containerView.addSubview(controlSeparate!)
        }
        
        var y = CGFloat(0)
        
        // Skip past controls already placed
        for (_, control) in controlSeparateList {
            y += control.frame.maxY - control.frame.minY + 20
        }
        
        // Add separate controls for each hardware
        for (hardware_name, hardware) in hardwareManager.hardwares {
            var control = controlSeparateList[hardware_name]
            
            if control == nil {
                control = ControlHardware()
                control!.setup(hardware, frame: containerView.frame)
                control!.center = CGPoint(x: control!.center.x, y: y)
                controlSeparateList[hardware_name] = control!
                controlSeparate!.addSubview(control!)
                y += control!.frame.maxY - control!.frame.minY + 20
            }
        }
        
        resizeToFitSubviews(controlSeparate!)
        
        repositionUI(controlSeparate!)
        
        return (controlSeparate, controlSeparateList)
    }
    
    static func repositionUI(controlSeparate : UIView?) {
        if controlSeparate != nil && controlSeparate?.superview != nil {
            let parent = controlSeparate!.superview!
            
            controlSeparate!.center = CGPoint(x: parent.center.x, y: controlSeparate!.center.y)
        }
    }
    
    static func removeAllUIControls(controlSeparate : UIView?, controlSeparateList : [String : ControlHardware]) -> (UIView?, [String : ControlHardware]) {
        var controlSeparate = controlSeparate
        var controlSeparateList = controlSeparateList
        
        for (_, control) in controlSeparateList {
            if control.superview != nil {
                control.removeFromSuperview()
            }
        }
        controlSeparateList.removeAll(keepCapacity: true)
        controlSeparate?.removeFromSuperview()
        controlSeparate = nil
        
        return (controlSeparate, controlSeparateList)
    }
    
    static func removeSingleUIControl(controlSeparateList : [String : ControlHardware], hardware_name : String) -> [String : ControlHardware] {
        var controlSeparateList = controlSeparateList
        
        if controlSeparateList[hardware_name] != nil {
            let control = controlSeparateList[hardware_name]!
            if control.superview != nil {
                control.removeFromSuperview()
            }
            controlSeparateList.removeValueForKey(hardware_name)
        }
        
        return controlSeparateList
    }
    
}
