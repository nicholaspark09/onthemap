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
        static let ApiID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
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
        static let Add = "/classes/StudentLocation"
    }
    
    struct JSONResponseKeys{
        
        // MARK: StudentInformation
        static let StudentsResults = "results"
        static let CreatedAt = "createdAt"
        static let ObjectId = "objectId"
        static let Error = "error"
    }
    
    struct URLKeys{
        static let UniqueKey = "UniqueKey"
    }
}