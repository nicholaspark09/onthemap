//
//  ParseDB.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

extension ParseClient{
    
    
    func addLocation(var dictionary: [String:AnyObject], completionHandlerForAdd: (result: StudentInformation?,error: String?) -> Void){
        let params = [String:AnyObject]()
        let jsonBody = "{\"uniqueKey\": \"\(dictionary[StudentInformation.Keys.UniqueKey]!)\", \"firstName\": \"\(dictionary[StudentInformation.Keys.FirstName]!)\", \"lastName\": \"\(dictionary[StudentInformation.Keys.LastName]!)\",\"mapString\": \"\(dictionary[StudentInformation.Keys.MapString]!)\", \"mediaURL\": \"\(dictionary[StudentInformation.Keys.MediaURL]!)\",\"latitude\": \(dictionary[StudentInformation.Keys.Latitude]!), \"longitude\": \(dictionary[StudentInformation.Keys.Longitude]!)}"
        print("The json body looks like : \(jsonBody)")
        httpPost(Methods.Add, parameters: params, jsonBody: jsonBody){(results,error) in
            if let error = error{
                completionHandlerForAdd(result: nil, error: error.localizedDescription)
            }else{
                if let created = results[JSONResponseKeys.CreatedAt] as? String{
                    dictionary[StudentInformation.Keys.CreatedAt] = created
                    dictionary[StudentInformation.Keys.UpdatedAt] = created
                    dictionary[StudentInformation.Keys.ObjectId] = results[JSONResponseKeys.ObjectId] as! String
                    let student = StudentInformation.init(dictionary: dictionary)
                    completionHandlerForAdd(result: student, error: nil)
                }else{
                    completionHandlerForAdd(result: nil, error: "Couldn't find the data in the results")
                }
            }
        }

        
    }
    
    func find(userKey: String!, completionHandlerForGet: (result: StudentInformation?, error: NSError?) -> Void){
        let params = [String:AnyObject]()
        let uniqueKey = UdacityClient.sharedInstance().accountKey!
        var mutableMethod = Methods.Query
        let keyString = uniqueKey
        mutableMethod = substituteKeyInMethod(mutableMethod, key: URLKeys.UniqueKey, value: keyString)!
        httpGet(mutableMethod, parameters: params){(results,error) in
            if let results = results[JSONResponseKeys.StudentsResults] as? [[String:AnyObject]]{
                let students = StudentInformation.studentsFromResults(results)
                if students.count > 0{
                    completionHandlerForGet(result: students[0], error: nil)
                }else{
                    completionHandlerForGet(result: nil, error: NSError(domain: "find Method", code: 0, userInfo: [NSLocalizedDescriptionKey: "No Student Information Found"]))
                }
            }else{
                completionHandlerForGet(result: nil, error: NSError(domain: "find Method", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error getting student"]))
            }
        }
    }
    
    // MARK: Index - Allows for indexing from Parse
    func index(limit: Int!, skip: Int, order: String!,completionHandlerForIndex: (result: [StudentInformation]?, error: NSError?) -> Void){
        var params = [String:AnyObject]()
        params = [ParameterKeys.Limit : limit, ParameterKeys.Skip : skip,ParameterKeys.Order : order]
        httpGet(Methods.Index, parameters: params){(results,error) in
            
            if let results = results[JSONResponseKeys.StudentsResults] as? [[String:AnyObject]] {
                let students = StudentInformation.studentsFromResults(results)
                completionHandlerForIndex(result: students, error: nil)
            }else{
                completionHandlerForIndex(result: nil, error: NSError(domain: "index parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse index"]))
            }
        }
    }
}
