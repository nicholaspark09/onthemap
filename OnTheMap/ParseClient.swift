//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

class ParseClient: NSObject{
    
    var session = NSURLSession.sharedSession()
    
    
    
    override init(){
        super.init()
    }
    
    // MARK: GET requests
    
    func httpGet(method: String, parameters: [String : AnyObject], completionHandlerForGET:(result:AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        let request = NSMutableURLRequest(URL: urlFromParameters(parameters, withPathExtension: method))
        //Must add in the keys given so that Parse knows it's from Udacity
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("The data was \(dataString)")
            //Just so I can see the actual url on debug
            let url = request.URL?.absoluteString
            print("The url is \(url!)")
            func sendError(error: String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(result:nil,error: NSError(domain:"httpGet", code: 1, userInfo:userInfo))
            }
            /* GUARD: Was there an error? */
            guard (error == nil) else{
                sendError("There was an error with the request: \(error)")
                return
            }
            /* GUARD: did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else{
                sendError("Your request sent back a non 200 response")
                return
            }
            
            /* GUARD: Was there any data? */
            guard let data = data else{
                sendError("No data sent back by request")
                return
            }
            self.convertDataWithCompletion(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        task.resume()
        return task
    }
    
    
    // MARK: POST requests
    func httpPost(method: String, parameters: [String : AnyObject], jsonBody: String,completionHandlerForPOST:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        let request = NSMutableURLRequest(URL: urlFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
 
            func sendError(error: String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPOST(result:nil,error: NSError(domain:"httpPost", code: 1, userInfo:userInfo))
            }
             
             /* GUARD: Was there an error? */
             guard (error == nil) else{
             sendError("There was an error with the request: \(error)")
             return
             }
             /* GUARD: did we get a successful 2XX response? */
             guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else{
             sendError("Your request sent back a non 2xx response")
             return
             }
             
             /* GUARD: Was there any data? */
             guard let data = data else{
             sendError("No data sent back by request")
             return
             }
            
            self.convertDataWithCompletion(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        task.resume()
        return task
    }
    
    // MARK: Get Clean URL Parameters
    func urlFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL{
        
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key,value) in parameters {
            let qItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(qItem)
        }
        return components.URL!
    }
    
    // MARK: Convert JSON to Objects
    private func convertDataWithCompletion(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void){
        var parsedResult: AnyObject!
        do{
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse as json: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain:"convertDataWithCompletionHandler",code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(result:parsedResult, error:nil)
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> ParseClient {
        struct Singleton{
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    // substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    
}