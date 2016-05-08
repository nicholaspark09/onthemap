//
//  ParseDB.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/8/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

class ParseDB: NSObject{
    
    var students = [StudentInformation]()

    
    // MARK: SharedInstance
    static let sharedInstance = ParseDB()
    private override init(){}
}