//
//  Helper.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 01/11/2015.
//  Copyright © 2015 Muhammed Miah. All rights reserved.
//

import Foundation
import UIKit

// From https://gist.github.com/hebertialmeida/9234391
func resizeToFitSubviews(view : UIView) {
    var w : CGFloat = 0
    var h : CGFloat = 0
    
    for v in view.subviews {
        let fw = v.frame.origin.x + v.frame.size.width
        let fh = v.frame.origin.y + v.frame.size.height
        w = max(fw, w);
        h = max(fh, h);
    }
    
    view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: w, height: h)
}

