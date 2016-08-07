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
    
    let hardwareUIManager = HardwareUIManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set up title label
        titleLabel.text = "Raspberry Pi Rover"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: self.view.frame.midX, y: titleLabel.bounds.midY+28)
        self.view.addSubview(titleLabel)
        
        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: titleLabel.frame.maxY, width: self.view.frame.width, height: statusLabel.bounds.height)
        self.view.addSubview(statusLabel)
        
        // Set up Hardware UI Manager
        hardwareUIManager.setup(self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

