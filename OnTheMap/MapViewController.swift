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
    
    
    func dropPin(){
        
    }
    
    func indexStudents(){
        ParseClient.sharedInstance().index(100, skip: 0, order: "-updatedAt"){(students,error) in
            if students != nil{
                print("Got back students with length \(students!.count)")
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
                    performOnMain(){
                        self.annotations.append(annotation)
                    }
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
