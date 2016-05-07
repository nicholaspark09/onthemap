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
        static let ApiPath = "/1"
    }
    
    struct ParameterKeys{
        static let Limit = "limit"
        static let Order = "order"
        static let Skip = "skip"
    }
    
    struct Methods{
        static let Index = "/classes/StudentLocation"
        static let Query = "/classes/StudentLocation?where={\"uniqueKey\":\"{UniqueKey}\"}"
    }
    
    struct JSONResponseKeys{
        
        // MARK: StudentInformation
        static let StudentsResults = "results"
    }
    
    struct URLKeys{
        static let UniqueKey = "UniqueKey"
    }
}