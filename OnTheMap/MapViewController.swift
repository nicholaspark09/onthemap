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
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    struct Constants{
        static let Title = "Map"
        static let PinReuseIdentifier = "Pin"
    }

    @IBOutlet var mapView: MKMapView!{
        didSet{
            mapView!.delegate = self
        }
    }
    
    var annotations = [MKPointAnnotation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.Title
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin"), landscapeImagePhone: UIImage(named:"Pin"), style: .Plain, target: self, action: #selector(MapViewProtocol.dropPin))
        
        indexStudents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.PinReuseIdentifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.PinReuseIdentifier)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
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
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    
    func dropPin(){
        ParseClient.sharedInstance().find(UdacityClient.sharedInstance().accountKey!){(results,error) in
            if error != nil{
                print("The error was \(error)")
            }else{
                print("\(results!.firstName)")
            }
        }
    }
    
    func indexStudents(){
        ParseClient.sharedInstance().index(100, skip: 0, order: "-updatedAt"){(students,error) in
            if students != nil{
                print("Got back students with length \(students!.count)")
                
                //Create temporary annotations in case you want to add more later
                var tempAnnotations = [MKAnnotation]()
                for student in students!{
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
                    
                    //Make sure this happens on the main thread
                   
                    tempAnnotations.append(annotation)
                    self.annotations.append(annotation)
                }
                performOnMain(){
                    print("You should be displaying annotations")
                    self.mapView.addAnnotations(tempAnnotations)
                }
            }else{
                performOnMain(){
                    print(error)
                }
            }
        }
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
