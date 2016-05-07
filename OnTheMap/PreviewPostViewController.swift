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

    
    var placemark: CLPlacemark?
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func submitClicked(sender: UIButton) {
        
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
