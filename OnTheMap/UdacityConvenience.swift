//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/8/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

extension UdacityClient{
    
    func login(email: String, password: String, completionHandler: (found: Bool, errorString: String?) -> Void){
        let params = [String:AnyObject]()
        let jsonBody = "{\"udacity\": {\"username\":\"\(email)\",\"password\":\"\(password)\"}}"
        UdacityClient.sharedInstance.httpPost(Methods.Login, parameters: params, jsonBody: jsonBody){ (results,error) in
            
            func sendError(error: String){
                completionHandler(found:false, errorString: error)
            }
            
            guard (error == nil) else{
                sendError("There was an error: \(error!.localizedDescription)")
                return
            }

            /*
            if let error = error{
                completionHandler(found: false, errorString: error.localizedDescription)
                print("Error: \(error)")
            }else{
                print("Found results: \(results)")
                if let originalerror = results[UdacityClient.JSONResponseKeys.Error] as? String{
                    if let status = results[UdacityClient.JSONResponseKeys.StatusCode] as? Int{
                        if status >= 200 && status <= 299 {
                             completionHandler(found: false, errorString: "Couldn't connect to server")
                        }else{
                             completionHandler(found: false, errorString: originalerror)
                        }
                    }
                }else{
            */
            guard let results = results else{
                sendError("No data sent back")
                return
            }
            if let status = results[JSONResponseKeys.StatusCode] as? Int{
                if status != 400 {
                    let error = results[JSONResponseKeys.Error] as! String
                    sendError(error)
                    return
                }
            }
                    if let account = results[UdacityClient.JSONResponseKeys.Account] as? [String:AnyObject]{
                        UdacityClient.sharedInstance.accountKey = account[UdacityClient.JSONResponseKeys.AccountKey] as? String
                    }
                    if let session = results[UdacityClient.JSONResponseKeys.Session] as? [String:AnyObject]{
                        UdacityClient.sharedInstance.sessionID = session[UdacityClient.JSONResponseKeys.SessionId] as? String
                        UdacityClient.sharedInstance.sessionExpiration = session[UdacityClient.JSONResponseKeys.SessionExpiration] as? String
                        completionHandler(found: true, errorString: nil)
                    }
            
        
        }
    }
    
    func logout(completionHandlerForLogout:(results: Bool, error: String?) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func sendError(error: String){
                completionHandlerForLogout(results: false, error: error)
            }
            guard (error == nil) else{
                sendError("Error: \(error)")
                return
            }
            guard let data = data else{
                sendError("No data sent back by request")
                return
            }

            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            guard newData.length > 0 else{
                sendError("No data returned")
                return
            }
            let string = NSString(data: newData, encoding: NSUTF8StringEncoding)
            print("Returned data: \(string)")
            self.convertDataWithCompletion(newData){(results,error) in
                if let session = results[JSONResponseKeys.Session] as? [String:AnyObject]{
                    print("You found a session \(session[JSONResponseKeys.SessionId])")
                    //You found the return body so you have to set the account key to nil
                    UdacityClient.sharedInstance.accountKey = nil
                    UdacityClient.sharedInstance.sessionID = nil
                    UdacityClient.sharedInstance.sessionExpiration = nil
                    completionHandlerForLogout(results: true, error: nil)
                }
            }
            
        }
        task.resume()
    }
    
    func viewProfile(completionHandler:(results:AnyObject?, error: NSError?) -> Void){
        var mutableMethod = Methods.ViewProfile
        mutableMethod = substituteKeyInMethod(mutableMethod, key: ParameterKeys.UserId, value: accountKey!)!
        httpGet(mutableMethod, parameters: [String:AnyObject]()){ (results,error) in
            if let error = error{
                completionHandler(results: nil, error: NSError(domain: "viewProfile Method", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error in viewing profile: \(error)"]))
            }else{
                if let user = results[JSONResponseKeys.User] as? [String:AnyObject]{
                    completionHandler(results: user, error: nil)
                }else{
                    completionHandler(results: nil, error: NSError(domain: "viewProfile Method", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error in parsing the returned garble"]))
                }
            }
        }
    }
    
}