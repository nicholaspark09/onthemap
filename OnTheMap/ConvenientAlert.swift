//
//  ConvenientAlert.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/9/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    struct UIViewConstants{
        static let AlertTitle = "Error"
        static let AlertButtonTitle = "OK"
    }
    
    func simpleError(message: String){
        performOnMain(){
            let alert = UIAlertController(title: UIViewConstants.AlertTitle, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: UIViewConstants.AlertButtonTitle, style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
