//
//  ViewController.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 30/07/2016.
//  Copyright © 2016 Muhammed Miah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let titleLabel : UILabel! = UILabel()
    var statusLabel : UILabel!
    let ipAddressInput = UITextField()
    let submitButton = UIButton(type: .System)
    let stopButton = UIButton(type: .System)
    
    let hardwareUIManager = HardwareUIManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Load saved data
        let dataIPAddress = PlistManager.sharedInstance.getValueForKey("ipaddress") as! String
        
        // Set up title label
        titleLabel.text = "Raspberry Pi Rover"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: self.view.frame.midX, y: titleLabel.bounds.midY + 16)
        self.view.addSubview(titleLabel)
        
        // IP Address input box
        ipAddressInput.frame.size = CGSize(width: self.view.frame.width * 0.7, height: 31)
        ipAddressInput.center = CGPoint(x: self.view.frame.midX,
                                        y: titleLabel.frame.maxY + ipAddressInput.frame.height/2 + 4)
        ipAddressInput.layer.borderWidth = 1
        ipAddressInput.layer.borderColor = UIColor.grayColor().CGColor
        ipAddressInput.text = dataIPAddress
        ipAddressInput.textAlignment = .Center
        self.view.addSubview(ipAddressInput)
        
        // Go button
        submitButton.setTitle("Go", forState: .Normal)
        submitButton.frame = CGRect(x: ipAddressInput.frame.maxX + 8, y: ipAddressInput.frame.midY - 15,
                                    width: 31, height: 31)
        submitButton.addTarget(self, action: #selector(submitIpAddress), forControlEvents: .TouchUpInside)
        self.view.addSubview(submitButton)
        
        // Stop button
        stopButton.setTitle("Stop", forState: .Normal)
        stopButton.frame = CGRect(x: ipAddressInput.frame.minX - 8 - 42, y: ipAddressInput.frame.midY - 15,
                                  width: 42, height: 31)
        stopButton.addTarget(self, action: #selector(stop), forControlEvents: .TouchUpInside)
        self.view.addSubview(stopButton)
        
        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: ipAddressInput.frame.maxY + 8,
                                   width: self.view.frame.width, height: statusLabel.bounds.height)
        self.view.sendSubviewToBack(statusLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submitIpAddress() {
        stop()
        
        Config.updateRoverIPAddress(ipAddressInput.text!)
        
        // Save IP Address
        PlistManager.sharedInstance.saveValue(ipAddressInput.text!, forKey: "ipaddress")
        
        // Set up Hardware UI Manager
        hardwareUIManager.setup(self.view)
        
        if statusLabel.superview == nil {
            self.view.addSubview(statusLabel)
        }
        
        // Close keyboard
        self.view.endEditing(true)
    }
    
    func stop() {
        hardwareUIManager.removeUI()
        
        if statusLabel.superview != nil {
            statusLabel.removeFromSuperview()
        }
    }

}

