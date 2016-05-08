//
//  InformationPostViewController.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit
import MapKit

@objc protocol InformationPostProtocol{
    func hideKeyboard()
}

class InformationPostViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {

    struct Constants{
        static let AlertTitle = "Error"
        static let AlertButtonTitle = "Ok"
        static let PreviewPostSegue = "PreviewPost Segue"
    }
    
    var studentInformation: StudentInformation?
    var currentPlacemark: CLPlacemark?{
        didSet{
            performOnMain(){
                self.findMapButton.enabled = true
            }
        }
    }
    @IBOutlet var activityIndicator: UIActivityIndicatorView!{
        didSet{
            activityIndicator!.hidesWhenStopped = true
            activityIndicator.stopAnimating()
        }
    }
    @IBOutlet var textField: UITextField!{
        didSet{
            textField!.delegate = self
        }
    }
    @IBOutlet var findMapButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(InformationPostProtocol.hideKeyboard))
        view.addGestureRecognizer(tap)
    }

    
    @IBAction func findMapButtonClicked(sender: UIButton) {
        performSegueWithIdentifier(Constants.PreviewPostSegue, sender: nil)
    }
    
    
    //Just clicked on the textfield -- Clear it out
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    //Clicked enter in the textfield, do the search if there's something in it
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let text = textField.text
        if text!.characters.count > 1 {
            findOnMap(text!)
        }
        return true
    }
    
    
    @IBAction func cancelClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: FindGeolocation
    func findOnMap(location: String){
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        CLGeocoder().geocodeAddressString(location){ (placemarks, error) in
            if error == nil{
                if placemarks != nil && placemarks!.count > 0 {
                    //Get the first placemark
                    self.currentPlacemark = placemarks![0]
                }
            }else{
                performOnMain(){
                    let alert = UIAlertController(title: Constants.AlertTitle, message: "Couldn't get the address: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: Constants.AlertButtonTitle, style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.findMapButton.enabled = true
                }
            }
            performOnMain(){
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
            }
        }
    }
    
    //Hide the keyboard
    func hideKeyboard(){
        view.endEditing(true)
    }
    

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.PreviewPostSegue{
            if let ppc = segue.destinationViewController as? PreviewPostViewController{
                ppc.placemark = currentPlacemark
                ppc.mapString = textField.text!
                ppc.modalPresentationStyle = UIModalPresentationStyle.Popover
                ppc.popoverPresentationController!.delegate = self
            }
        }
    }

    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}
