//
//  RestfulHardware.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 30/07/2016.
//  Copyright © 2016 Muhammed Miah. All rights reserved.
//

import Foundation

class RestfulHardware : NSObject, NSURLSessionDataDelegate {
    
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    var session : NSURLSession! = nil
    let baseUrl = Config.roverUrl
    
    var callbackFunctions : [[String : Double] -> Void] = []
    
    // Properties to help keep hardware values updated, without sending out too many requests
    var allHardwareLastRefreshTime : NSTimeInterval? = nil
    var allHardwareOngoingRequestTime : NSTimeInterval? = nil
    
    var lastUpdateTimes : [String : NSTimeInterval] = [:]
    var ongoingRequestTimes : [String : NSTimeInterval] = [:]
    
    override init() {
        super.init()
        session = NSURLSession(configuration: self.config, delegate: self, delegateQueue: nil)
    }
    
    func addCallbackFunction(f : [String : Double] -> Void) {
        callbackFunctions.append(f)
    }
    
    func getHardwareValue(name: String) {
        let url = baseUrl + "hardware/" + name + "/"
        call(url, callback: updateHardwareCallback)
    }
    func setHardwareValue(name: String, value: Double) {
        let currentTime = NSDate().timeIntervalSince1970
        removeInactiveOngoingRequests()
      
        if ongoingRequestTimes[name] == nil &&
            (lastUpdateTimes[name] == nil || currentTime - lastUpdateTimes[name]! >= 0.2) {
            
//            print("Setting", name, "to", String(value))
            let url = baseUrl + "hardware/" + name + "/set/" + String(value)
            call(url, callback: updateHardwareCallback)
            
            ongoingRequestTimes[name] = NSDate().timeIntervalSince1970
        }
    }
    func refreshAllHardwareValues() {
        let currentTime = NSDate().timeIntervalSince1970
        removeInactiveOngoingRequests()
        
        if allHardwareOngoingRequestTime == nil &&
            (allHardwareLastRefreshTime == nil || currentTime - allHardwareLastRefreshTime! >= 1) {
            
            let url = baseUrl + "hardware/"
            call(url, callback: updateHardwareListCallback)
            
            allHardwareOngoingRequestTime = NSDate().timeIntervalSince1970
        }
    }
    
    func updateHardwareCallback(url_minus_base : String, json: AnyObject) {
        let hardwareValues = getHardwareValuesFromJson(json)
        
        // Send data to callback functions
        for f in callbackFunctions {
            f(hardwareValues)
        }
        
        // Refresh last update times
        let currentTime = NSDate().timeIntervalSince1970
        for (hardware_name, _) in hardwareValues {
            lastUpdateTimes[hardware_name] = currentTime
            
            // The last time the value was sent to the hardware
            if ongoingRequestTimes[hardware_name] != nil {
                ongoingRequestTimes.removeValueForKey(hardware_name)
            }
        }
    }
    func updateHardwareListCallback(url_minus_base : String, json: AnyObject) {
        let hardwareValues = getHardwareValuesFromJson(json)
        
        // Send data to callback functions
        for f in callbackFunctions {
            f(hardwareValues)
        }
        
        // Reset last update times for the individual hardware
        let currentTime = NSDate().timeIntervalSince1970
        for (hardware_name, _) in hardwareValues {
            lastUpdateTimes[hardware_name] = currentTime
        }
        
        // Reset last update times for the full hardware list
        if hardwareValues.count > 1 {
            allHardwareLastRefreshTime = NSDate().timeIntervalSince1970
            allHardwareOngoingRequestTime = nil
        }
    }
    
    func getHardwareValuesFromJson(json : AnyObject) -> [String : Double] {
        var hardwareValues : [String : Double] = [:]
        
        // Parse and clean data
        if let dict = json as? [String : AnyObject] {
            for entry in dict {
                let hardwareName = entry.0
                let hardwareData = entry.1
                
                if let dict2 = hardwareData as? [String : AnyObject] {
                    for entry2 in dict2 {
                        let value = entry2.1
                        
                        if let hardwareValue = value as? Double {
                            hardwareValues[hardwareName] = hardwareValue
                        }
                    }
                }
            }
        }
        
        return hardwareValues
    }
    
    func call(url: String, callback: (String, AnyObject) -> Void) {
        let urlRequest = NSURLRequest(URL: NSURL(string: url)!)
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            guard error == nil else {
//                let url = error!.userInfo["NSErrorFailingURLStringKey"]
                print(url, error)
                return
            }
            guard response != nil else {
                print("[Warning] No response")
                return
            }
            guard response!.URL != nil else {
                print("[Warning] Response has no associated URL")
                return
            }
            guard response!.URL!.absoluteString.containsString(self.baseUrl) else {
                print("[Warning] Response URL does not contain the base URL:", response!.URL!.absoluteString)
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
            
            // Infer encoding
            var usedEncoding = NSUTF8StringEncoding // Fallback encoding
            if let encodingName = httpResponse.textEncodingName {
                let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName))
                if encoding != UInt(kCFStringEncodingInvalidId) {
                    usedEncoding = encoding
                }
            }
            
            // Parse response as string
            guard let content = String(data: data!, encoding: usedEncoding) else {
                print("[Warning] Unable to parse downloaded data")
                return
            }
            
            var json : AnyObject? = nil
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
            } catch {
                print("[Warning] Unable to extract JSON data")
                print(content)
                return
            }
            
            let url_minus_base = response!.URL!.absoluteString.substringFromIndex(self.baseUrl.endIndex)
            
            callback(url_minus_base, json!)
        }
        task.resume()
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        // Look at bottom of https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/AuthenticationChallenges.html
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.protectionSpace.serverTrust != nil { // Maybe place this within the above block
                completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
            }
        }
    }
    
    func removeInactiveOngoingRequests() {
        let currentTime = NSDate().timeIntervalSince1970
        
        for (hardware_name, time) in ongoingRequestTimes {
            if currentTime - time > 15 {
                ongoingRequestTimes.removeValueForKey(hardware_name)
            }
        }
        
        if allHardwareOngoingRequestTime != nil {
            if currentTime - allHardwareOngoingRequestTime! > 15 {
                allHardwareOngoingRequestTime = nil
            }
        }
    }
    
}
