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
    let baseUrl = "https://www.dropbox.com/s/ie0rwi5bynp2jkr/test.json?dl=1"
//    let baseUrl = "https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=perl&site=stackoverflow"
    
    var callbackFunctions : [[String : Double] -> Void] = []
    
    // Properties to help keep hardware values updated, without sending out too many requests
    var hardwareListLastUpdateTime = NSDate().timeIntervalSince1970
    var hardwareListOngoingUpdateRequestTime : NSTimeInterval? = nil
    
    override init() {
        super.init()
        session = NSURLSession(configuration: self.config, delegate: self, delegateQueue: nil)
    }
    
    func addCallbackFunction(f : [String : Double] -> Void) {
        callbackFunctions.append(f)
    }
    
    func getHardwareValue(name: String) {
        let url = baseUrl //+ "hardware/" + name + "/"
        call(url, callback: updateHardwareListCallback)
    }
    func setHardwareValue(name: String, value: Double) {
        print("Setting", name, "to", String(value))
        let url = baseUrl //+ "hardware/" + name + "/set/" + String(value)
        call(url, callback: updateHardwareListCallback)
    }
    func updateHardwareList() {
        if hardwareListOngoingUpdateRequestTime == nil {
            
            let url = baseUrl //+ "hardware/"
            call(url, callback: updateHardwareListCallback)
            
            hardwareListOngoingUpdateRequestTime = NSDate().timeIntervalSince1970
        }
    }
    
    func updateHardwareListCallback(json: AnyObject) {
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
        
        // Send data to callback functions
        for f in callbackFunctions {
            f(hardwareValues)
        }
        
        // Reset last update times
        if hardwareValues.count > 1 {
            hardwareListLastUpdateTime = NSDate().timeIntervalSince1970
            hardwareListOngoingUpdateRequestTime = nil
        }
    }
    
    func call(url: String, callback: (AnyObject) -> Void) {
        let urlRequest = NSURLRequest(URL: NSURL(string: url)!)
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            guard error == nil else {
                print(error)
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
            
//            // Infer encoding
//            var usedEncoding = NSUTF8StringEncoding // Fallback encoding
//            if let encodingName = httpResponse.textEncodingName {
//                let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName))
//                if encoding != UInt(kCFStringEncodingInvalidId) {
//                    usedEncoding = encoding
//                }
//            }
//            
//            // Parse response as string
//            guard let content = String(data: data!, encoding: usedEncoding) else {
//                print("[Warning] Unable to parse downloaded data")
//                return
//            }
//            print(content)
            
            var json : AnyObject? = nil
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
            } catch {
                print("[Warning] Unable to extract JSON data")
                return
            }
            
            callback(json!)
        }
        task.resume()
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        // Look at bottom of https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/AuthenticationChallenges.html
        
        print("Authentication method: " + challenge.protectionSpace.authenticationMethod)
        print("Authentication method to match with: " + NSURLAuthenticationMethodServerTrust)
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            print("Authentication method matches. Obtain the serverTrust information from the protection space")
        }
        
        if challenge.protectionSpace.serverTrust != nil { // Maybe place this within the above block
            print("HANDLING AUTHENTICATION CHALLENGE")
            completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
        }
    }
    
    func handleInactiveHardwareListOngoingUpdateRequest() {
        if hardwareListOngoingUpdateRequestTime != nil {
            let currentTime = NSDate().timeIntervalSince1970
            let diff = currentTime - hardwareListOngoingUpdateRequestTime!
            if diff > 15 {
                hardwareListOngoingUpdateRequestTime = nil
            }
        }
    }
    
}
