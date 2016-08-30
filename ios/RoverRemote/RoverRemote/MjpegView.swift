//
//  MjpegView.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 07/08/2016.
//  Copyright © 2016 Muhammed Miah. All rights reserved.
//

import Foundation
import UIKit

class MjpegView : UIImageView, NSURLSessionDataDelegate {
    
    let uv4lServer = Config.uv4lUrl
    let urlResizeRequest = "panel?width=192&height=128&format=875967048&134217741=10" // Last parameter is the framerate
    let urlMjpegStream = "stream/video.mjpeg"
    
    var endMarkerData = NSData()
    var receivedData = NSMutableData()
    
    var task : NSURLSessionDataTask?
    
    override init(frame : CGRect) {
        //self.frame = CGRect(x: 0, y: 60, width: self.view.frame.width, height: self.view.frame.height-60)
        super.init(frame: frame)
        
        self.contentMode = .ScaleAspectFit
        self.clearsContextBeforeDrawing = false
        
        self.endMarkerData = NSData(bytes: [0xFF, 0xD9] as [UInt8], length: 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        if task?.state != .Running {
            // Edit width and height, so streaming is not too slow
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
            
            let url = uv4lServer + urlResizeRequest
            let request = NSURLRequest(URL: NSURL(string: url)!)
            task = session.dataTaskWithRequest(request) {
                (data, response, error) -> Void in
                
                guard error == nil else {
                    if error!.code == -999 {
                        //print(url, "cancelled")
                    } else {
                        print(url, error!)
                    }
                    return
                }
                guard response != nil else {
                    print("[Warning] No response")
                    return
                }
                guard data != nil else {
                    print("[Warning] No data")
                    return
                }
                
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                guard statusCode == 200 else {
                    print("[Warning] Status code " + String(statusCode))
                    return
                }
                
                // Now asynchronously connect to the MJPEG stream
                dispatch_async(dispatch_get_main_queue()) {
                    self.startMjpegStream()
                }
            }
            task!.resume()
        }
    }
    
    func startMjpegStream() {
        // http://stackoverflow.com/questions/26692617/ios-and-live-streaming-mjpeg
        // https://github.com/mateagar/Motion-JPEG-Image-View-for-iOS/blob/master/MotionJpegImageView/MotionJpegImageView.mm
        // http://www.stefanovettor.com/2016/03/30/ios-mjpeg-streaming/
        
        if task?.state != .Running {
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
            
            let url = uv4lServer + urlMjpegStream
            let request = NSURLRequest(URL: NSURL(string: url)!)
            task = session.dataTaskWithRequest(request)
            task!.resume()
        }
    }
    
    func stop() {
        task?.cancel()
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if (dataTask.currentRequest?.URL?.absoluteString.containsString(urlMjpegStream))! {
            receivedData.appendData(data)
        } else {
            print("Data coming in for request", dataTask.currentRequest?.URL?.absoluteString)
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        if (dataTask.currentRequest?.URL?.absoluteString.containsString(urlMjpegStream))! {
            let imageData = NSData(data: self.receivedData)
            if imageData.length > 0,
                let image = UIImage(data: imageData) {
                
                //http://stackoverflow.com/questions/19179185/how-to-asynchronously-load-an-image-in-an-uiimageview/19251240#19251240
                // Draw the image on the background thread before the main thread
                // This is meant to stop flickering sometimes
                UIGraphicsBeginImageContext(CGSizeMake(1,1))
                let context = UIGraphicsGetCurrentContext();
                CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
                UIGraphicsEndImageContext();
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.image = image
                }
            }
            
            receivedData = NSMutableData()
            
            // Enable the didReceiveData delegate method
            completionHandler(.Allow)
        } else {
            print("Request has come from", dataTask.currentRequest?.URL?.absoluteString)
        }
    }
    
}