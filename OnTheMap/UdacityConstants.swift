//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

extension UdacityClient{
    struct Constants{
        static let ApiKey : String = ""
        static let ApiScheme : String = "https"
        static let ApiHost : String = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    struct JSONResponseKeys{
        static let StatusCode = "status"
        static let Error = "error"
        static let Account = "account"
        static let Session = "session"
        static let AccountKey = "key"
        static let SessionId = "id"
        static let SessionExpiration = "expiration"
    }
    
}