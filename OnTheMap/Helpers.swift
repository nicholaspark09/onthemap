//
//  Helpers.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

func performOnMain(updates: () -> Void){
    dispatch_async(dispatch_get_main_queue()){
            updates()
    }
}


