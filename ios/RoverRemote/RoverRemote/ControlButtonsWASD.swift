//
//  ControlButtonsWASD.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 29/10/2015.
//  Copyright © 2015 Muhammed Miah. All rights reserved.
//

import UIKit

class ControlButtonsWASD : UIView {
    
    var buttonUp : UIButton!
    var buttonDown : UIButton!
    var buttonLeft : UIButton!
    var buttonRight : UIButton!
    
    var buttonUpPressed = false
    var buttonDownPressed = false
    var buttonLeftPressed = false
    var buttonRightPressed = false
    
    var hardwareManager : HardwareManager! // Make sure to assign this straight after initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        buttonUp = ControlButtonsWASD.button("up", tag: 1)
        buttonUp.center = CGPoint(x: 0, y: -buttonUp.frame.height*1.2)
        self.addSubview(buttonUp)
        
        buttonDown = ControlButtonsWASD.button("down", tag: 2)
        buttonDown.center = CGPoint(x: 0, y: buttonDown.frame.height*1.2)
        self.addSubview(buttonDown)
        
        buttonLeft = ControlButtonsWASD.button("turnLeft", tag: 3)
        buttonLeft.center = CGPoint(x: -buttonLeft.frame.height*1.2, y: 0)
        self.addSubview(buttonLeft)
        
        buttonRight = ControlButtonsWASD.button("turnRight", tag: 4)
        buttonRight.center = CGPoint(x: buttonRight.frame.height*1.2, y: 0)
        self.addSubview(buttonRight)
        
        // Set bounds of view so that touch events are received correctly
        self.bounds = CGRect(
            x: buttonLeft.frame.minX,
            y: buttonUp.frame.minY,
            width: buttonRight.frame.maxX-buttonLeft.frame.minX,
            height: buttonDown.frame.maxY-buttonUp.frame.minY)
        
        addEvents()
    }
    
    static func button(name : String, tag : Int) -> UIButton {
        // Icons were made by Freepik and SimpleIcon from www.flaticon.com and is licensed under CC BY 3.0
        let width = min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        
        //        let temp = "ffmpeg -i"
        //        system(temp)
        
        let button = UIButton()
        button.tag = tag
        button.setBackgroundImage(UIImage(named: name), forState: .Normal)
        button.setBackgroundImage(UIImage(named: name+"Highlight"), forState: .Highlighted)
        button.sizeToFit()
        button.frame = CGRect(x: 0, y: 0, width: width*0.1, height: width*0.1)
        return button
    }
    
    func addEvents() {
        buttonUp.addTarget(self, action: #selector(controlButtonPressed(_:)), forControlEvents: .TouchDown)
        buttonDown.addTarget(self, action: #selector(controlButtonPressed(_:)), forControlEvents: .TouchDown)
        buttonLeft.addTarget(self, action: #selector(controlButtonPressed(_:)), forControlEvents: .TouchDown)
        buttonRight.addTarget(self, action: #selector(controlButtonPressed(_:)), forControlEvents: .TouchDown)
        
        buttonUp.addTarget(self, action: #selector(controlButtonReleased(_:)),
                           forControlEvents: [.TouchCancel, .TouchDragExit, .TouchUpInside])
        buttonDown.addTarget(self, action: #selector(controlButtonReleased(_:)),
                             forControlEvents: [.TouchCancel, .TouchDragExit, .TouchUpInside])
        buttonLeft.addTarget(self, action: #selector(controlButtonReleased(_:)),
                             forControlEvents: [.TouchCancel, .TouchDragExit, .TouchUpInside])
        buttonRight.addTarget(self, action: #selector(controlButtonReleased(_:)),
                              forControlEvents: [.TouchCancel, .TouchDragExit, .TouchUpInside])
    }
    
    func controlButtonPressed(sender:UIButton!) {
        // print("WASD button", sender.tag, "pressed")
        
        switch sender.tag {
        case 1:
            buttonUpPressed = true
        case 2:
            buttonDownPressed = true
        case 3:
            buttonLeftPressed = true
        case 4:
            buttonRightPressed = true
        default: break
        }
        
        updateMotors()
    }
    
    func controlButtonReleased(sender:UIButton!) {
        // print("WASD button", sender.tag, "released")
        
        switch sender.tag {
        case 1:
            buttonUpPressed = false
        case 2:
            buttonDownPressed = false
        case 3:
            buttonLeftPressed = false
        case 4:
            buttonRightPressed = false
        default: break
        }
        
        updateMotors()
    }
    
    func updateMotors() {
        let up = buttonUpPressed && !buttonDownPressed
        let down = !buttonUpPressed && buttonDownPressed
        let left = buttonLeftPressed && !buttonRightPressed
        let right = !buttonLeftPressed && buttonRightPressed
        
        // print("WASD:", up, left, down, right)
        
        // Single button press
        let moveForward = up && !left && !right
        let moveBackward = down && !left && !right
        let rotateRight = right && !up && !down
        let rotateLeft = left && !up && !down
        let stop = !up && !down && !left && !right
        
        // Multiple button press
        let moveNE = up && right
        let moveNW = up && left
        let moveSE = down && right
        let moveSW = down && left
        
        if moveForward {
            hardwareManager.moveForward()
        } else if moveBackward {
            hardwareManager.moveBackward()
        } else if rotateLeft {
            hardwareManager.rotateLeft()
        } else if rotateRight {
            hardwareManager.rotateRight()
        } else if stop {
            hardwareManager.stop()
        } else if moveNE {
            hardwareManager.moveNE()
        } else if moveNW {
            hardwareManager.moveNW()
        } else if moveSE {
            hardwareManager.moveSE()
        } else if moveSW {
            hardwareManager.moveSW()
        }
    }
    
    static func updateUI(hardwareManager : HardwareManager, controlWASD : ControlButtonsWASD?, containerView : UIView) -> ControlButtonsWASD? {
        var controlWASD = controlWASD
        if hardwareManager.hardwares["motor-0"] != nil && hardwareManager.hardwares["motor-1"] != nil {
            if controlWASD == nil {
                // Arrows to control motors
                controlWASD = ControlButtonsWASD()
                controlWASD!.hardwareManager = hardwareManager
                containerView.addSubview(controlWASD!)
            }
            repositionUI(controlWASD)
        } else {
            if controlWASD != nil {
                if controlWASD!.superview != nil {
                    controlWASD!.removeFromSuperview()
                }
                controlWASD = nil
            }
        }
        return controlWASD
    }
    
    static func repositionUI(controlWASD : ControlButtonsWASD?) {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if controlWASD != nil && controlWASD?.superview != nil {
            let parent = controlWASD!.superview!
            
            if orientation.isPortrait {
                controlWASD!.center = CGPoint(x: parent.center.x, y: parent.center.y * 1.2)
            } else if orientation.isLandscape {
                controlWASD!.center = CGPoint(x: parent.center.x*0.66, y: parent.center.y*1.5)
            }
        }
    }
}


