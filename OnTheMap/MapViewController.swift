//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit
import MapKit

@objc protocol MapViewProtocol{
    func dropPin()
    func refreshStudents()
    func logout()
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    struct Constants{
        static let Title = "Map"
        static let PinReuseIdentifier = "Pin"
        static let InformationPostSegue = "InformationPost Segue"
        static let AlertTitle = "Error"
        static let AlertButtonTitle = "OK"
    }

    @IBOutlet var mapView: MKMapView!{
        didSet{
            mapView!.delegate = self
        }
    }
    
    var annotations = [MKPointAnnotation]()
    var loading = false
    var colors = [UIColor.redColor(),UIColor.blueColor(),UIColor.greenColor(),UIColor.orangeColor()]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.Title
        
        //Set the buttons right here
        let pinButton = UIBarButtonItem(image: UIImage(named: "Pin"), style: .Plain, target: self, action: #selector(MapViewProtocol.dropPin))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(MapViewProtocol.refreshStudents))
        navigationItem.setRightBarButtonItems([pinButton,refreshButton], animated: true)
        let logoutButtonTitle = UdacityClient.Constants.LogoutTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: logoutButtonTitle, style: .Plain, target: self, action: #selector(MapViewProtocol.logout))
        
        /**
            If there are already students in the local DB then there's no need to pull until
                the user presses refresh
            If there are no users, then load em up!
        **/
        if ParseDB.sharedInstance.students.count < 1{
            indexStudents()
        }
    }

    
    // MARK: - MKMapViewDelegate Add Pin to MapView
    //Change the color of the pin here
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.PinReuseIdentifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.PinReuseIdentifier)
            pinView!.canShowCallout = true
            //Tired of just seeing red...
            pinView!.pinTintColor = getColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                let url = NSURL(string: toOpen)
                if url != nil && app.canOpenURL(url!) {
                    app.openURL(url!)
                }else{
                    //Can't open the url so notify the user
                    let alert = UIAlertController(title: Constants.AlertTitle, message: "Not a valid url", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: Constants.AlertButtonTitle, style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func logout(){
        navigationItem.leftBarButtonItem?.title = UdacityClient.Constants.LoadingLabel
        navigationItem.leftBarButtonItem?.enabled = false
        UdacityClient.sharedInstance.logout(){(loggedOut,error) in
            if error != nil{
                self.simpleError(error!)
                return
            }
            if loggedOut{
                performOnMain(){
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }else{
                self.simpleError("Oops. Couldn't log you out from the account")
            }
        }
    }
    
    func dropPin(){

        performSegueWithIdentifier(Constants.InformationPostSegue, sender: nil)
    }
    
    func addAnnotations(){
        self.annotations = [MKPointAnnotation]()
        for student in ParseDB.sharedInstance.students{
            let lat = CLLocationDegrees(student.latitude as Double)
            let long = CLLocationDegrees(student.longitude as Double)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            self.annotations.append(annotation)
        }
        performOnMain(){
            print("You should be displaying annotations")
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    func indexStudents(){
        //One Pull Method at a time
        if !loading{
            loading = true
            ParseClient.sharedInstance.index(100, skip: 0, order: "-updatedAt"){(students,error) in
                
                if error != nil{
                    self.simpleError(error!.localizedDescription)
                    return
                }
                
                if students != nil{
                    
                    //Create temporary annotations in case you want to add more later

                    for student in students!{
                        ParseDB.sharedInstance.students.append(student)
                    }
                    self.addAnnotations()
                }else{
                    performOnMain(){
                        print(error)
                    }
                }
                //Make sure the user can refresh
                self.loading = false
            }
        }
    }
    
    func refreshStudents(){
        mapView.removeAnnotations(annotations)
        annotations = [MKPointAnnotation]()
        ParseDB.sharedInstance.students = [StudentInformation]()
        indexStudents()
    }
    
    func getColor() -> UIColor{
        var x = 0
        x = Int(arc4random_uniform(UInt32(colors.count)))
        return colors[x]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
