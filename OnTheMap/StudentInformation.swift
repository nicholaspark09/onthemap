//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

struct StudentInformation{
    
    
    // MARK: Keys
    struct Keys{
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    let objectId:String
    let firstName:String
    let lastName:String
    let mapString:String
    let mediaURL:String
    let latitude: NSNumber
    let longitude: NSNumber
    var uniqueKey:String?
    
    // MARK: Initializers
    
    // construct a TMDBMovie from a dictionary
    init(dictionary: [String:AnyObject]) {
        objectId = dictionary[Keys.ObjectId] as! String
        if let uniqueKeyString = dictionary[Keys.UniqueKey] as? String where uniqueKeyString.isEmpty == false{
            uniqueKey = uniqueKeyString
        }else{
            uniqueKey = ""
        }
        firstName = dictionary[Keys.FirstName] as! String
        lastName = dictionary[Keys.LastName] as! String
        mapString = dictionary[Keys.MapString] as! String
        mediaURL = dictionary[Keys.MediaURL] as! String
        latitude = dictionary[Keys.Latitude] as! NSNumber
        longitude = dictionary[Keys.Longitude] as! NSNumber
    }
    
    static func studentsFromResults(results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        
        return students
    }
}
