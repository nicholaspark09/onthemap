//
//  PreviewPostViewController.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit
import MapKit

@objc protocol PreviewPostProtocol{
    func hideKeyboard()
}

class PreviewPostViewController: UIViewController, UITextFieldDelegate {

    struct Constants{
        static let AlertTitle = "Error"
        static let AlertButtonTitle = "Ok"
        static let UnwindSegue = "UnwindToStudents Segue"
    }
    
    
    var placemark: CLPlacemark?
    var mapString: String = ""
    var studentInformation:StudentInformation?{
        didSet{
            //Just to check on log
            print("You pushed it with an object id of \(studentInformation!.objectId) and created at \(studentInformation!.createdAt)")
        }
    }
    
    @IBOutlet var linkTextField: UITextField!{
        didSet{
            linkTextField!.delegate = self
        }
    }
    @IBOutlet var mapKit: MKMapView!
    @IBOutlet var submitButton: UIButton!{
        didSet{
            submitButton.enabled = false
            submitButton.hidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if placemark != nil{
            self.mapKit.centerCoordinate = placemark!.location!.coordinate
            self.mapKit.addAnnotation(MKPlacemark.init(placemark: placemark!))
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(InformationPostProtocol.hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        linkTextField.resignFirstResponder()
        let text = linkTextField!.text!
        if text.characters.count < 1{
            submitButton.enabled = false
            submitButton.hidden = true
        }else{
            submitButton.enabled = true
            submitButton.hidden = false
        }
        return true
    }
    
    @IBAction func cancelClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func submitClicked(sender: UIButton) {

        let accountKey = UdacityClient.sharedInstance.accountKey!
        UdacityClient.sharedInstance.viewProfile(){(results,error) in
            if let error = error{
               self.simpleError(error.localizedDescription)
              return
            }
            if let results = results{
                var dictionary = [String:AnyObject]()
                dictionary[StudentInformation.Keys.FirstName] = results[UdacityClient.JSONResponseKeys.FirstName]!
                dictionary[StudentInformation.Keys.LastName] = results[UdacityClient.JSONResponseKeys.LastName]!
                dictionary[StudentInformation.Keys.UniqueKey] = accountKey
                dictionary[StudentInformation.Keys.MapString] = self.mapString
                dictionary[StudentInformation.Keys.MediaURL] = self.linkTextField!.text!
                dictionary[StudentInformation.Keys.Latitude] = self.placemark!.location!.coordinate.latitude
                dictionary[StudentInformation.Keys.Longitude] = self.placemark!.location!.coordinate.longitude
                dictionary[StudentInformation.Keys.CreatedAt] = ""
                dictionary[StudentInformation.Keys.UpdatedAt] = ""
                dictionary[StudentInformation.Keys.ObjectId] = ""
                
                    ParseClient.sharedInstance.addLocation(dictionary){(result,error) in
                        if error != nil{
                            self.simpleError(error!)
                            return
                        }
                        
                        if let student = result{
                            self.studentInformation = student
                            performOnMain(){
                                self.performSegueWithIdentifier(Constants.UnwindSegue, sender: nil)
                            }
                        }
                    }
            }
        }
        
    }
    /*
    // MARK: - Navigation


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.UnwindSegue{
            if let svc = segue.destinationViewController as? StudentsTableViewController{
                
            }
        }
    }
 */
    
    override var preferredContentSize: CGSize {
        get{
            return super.preferredContentSize
        }
        set{super.preferredContentSize = newValue}
    }
    
    //Hide the keyboard
    func hideKeyboard(){
        view.endEditing(true)
        if linkTextField.text?.characters.count > 0{
            submitButton.enabled = true
            submitButton.hidden = false
        }
    }

}
