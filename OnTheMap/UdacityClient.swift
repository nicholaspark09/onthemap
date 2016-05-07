//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

class UdacityClient: NSObject{

    
    var requestToken: String? = nil
    var sessionID : String? = nil
    //This is the actual User ID for Udacity
    /**
        This is poorly described in the project documentation
        I had to try the session id first and then used the account key >:/
    **/
    var accountKey: String?
    var sessionExpiration: String?
    
    var session = NSURLSession.sharedSession()
    
    
    override init(){
        super.init()
    }
    
    // MARK: GET requests
    
    func httpGet(method: String, parameters: [String : AnyObject], completionHandlerForGET:(result:AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        let request = NSMutableURLRequest(URL: urlFromParameters(parameters, withPathExtension: method))
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
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
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            var newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            func sendError(error: String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPOST(result:nil,error: NSError(domain:"httpPost", code: 1, userInfo:userInfo))
            }
            /**
                Using the data with 5 characters bumped throws everything off
                    I don't quite know what to do to get the response reading correctly
                    The response always fails
            
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
            **/

            self.convertDataWithCompletion(newData!, completionHandlerForConvertData: completionHandlerForPOST)
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
    class func sharedInstance() -> UdacityClient {
        struct Singleton{
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}
