//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

extension ParseClient{
    struct Constants{
        static let ApiKey : String = ""
        static let ApiScheme : String = "https"
        static let ApiHost : String = "api.parse.com"
        static let ApiPath = "/1/classes/StudentLocation"
    }
    
    struct ParameterKeys{
        static let Limit = "limit"
        static let Order = "order"
        static let Skip = "skip"
    }
    
    struct Methods{
        static let Index = "/classes/StudentLocation"
    }
    
    struct JSONResponseKeys{
        
        // MARK: StudentInformation
        static let StudentsResults = "results"
    }
}