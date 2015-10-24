//
//  MasterMapVC.swift
//  s65project
//
//  Created by Chi Zhang on 7/31/15.
//  Copyright (c) 2015 Chi Zhang. All rights reserved.
//
// https://www.youtube.com/watch?v=kkVI3njOlqU
// http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial

import UIKit
import CoreLocation
import MapKit
import Parse

class MasterMapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var eventList: [PFObject]?
    
    
    @IBOutlet weak var mapview: MKMapView!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    let regionRadius: CLLocationDistance = 500
    

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapview.setRegion(coordinateRegion, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        if let location = self.currentLocation {
            centerMapOnLocation(self.currentLocation!)
        }
        else {
            let defaultLocation:CLLocation = CLLocation(latitude: 42.3799895, longitude: -71.1153309)
            centerMapOnLocation(defaultLocation)
        }

        
        mapview.showsUserLocation = true
        println(mapview.userLocation.location)
        //mapview.setCenterCoordinate(mapview.userLocation.location.coordinate, animated: true)
        //let span = MKCoordinateSpanMake(0.05, 0.05)
        //let region = MKCoordinateRegion(center: mapview.userLocation.location.coordinate, span: span)
        //mapview.setRegion(region, animated: true)
        
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation
        userLocation: MKUserLocation!) {
            mapview.centerCoordinate = userLocation.location.coordinate
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.lookUp()
    }

    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                println("Error: " + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as! CLPlacemark
                self.currentLocation = manager.location
                let annotation = MKPointAnnotation()
                annotation.title = "Here"
                annotation.coordinate = pm.location.coordinate
                self.mapview.showAnnotations([annotation], animated: true)
                self.mapview.selectAnnotation(annotation, animated: true)
            }
        })
    }
    

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
    
    
    func lookUp() {
        var query = PFQuery(className:"FinalDemoData")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    self.eventList = objects
                    self.displayEvents()
                }
            } else {
                println("Error: \(error!)")
            }
        }
        
    }
    
    func displayEvents() {
        if let list = self.eventList {
            for event in list {
                let address = event[EventKeys.EventAddress] as! String
                var location: CLPlacemark?
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(address, completionHandler: {placemarks, error in
                    if error != nil {
                        println(error)
                        return
                    }
                    
                    if let place = placemarks[0] as? CLPlacemark {
                        let annotation = MKPointAnnotation()
                        annotation.title = "\(event[EventKeys.EventName]!)"
                        annotation.coordinate = place.location.coordinate
                        self.mapview.showAnnotations([annotation], animated: true)
                        self.mapview.selectAnnotation(annotation, animated: true)
                    }
                })
            }
        }
    }
    
    
}
