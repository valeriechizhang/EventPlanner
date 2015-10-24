//
//  MapVC.swift
//  s65project
//
//  Created by Chi Zhang on 7/28/15.
//  Copyright (c) 2015 Chi Zhang. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, MKMapViewDelegate{
    
    var eventName: String?
    var address: String?
    var location: CLPlacemark?
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(self.address, completionHandler: {placemarks, error in
            if error != nil {
                println(error)
                return
            }
            
            if let place = placemarks[0] as? CLPlacemark {
                self.location = place
            }
        })
        
        if let loc = self.location {
            let annotation = MKPointAnnotation()
            annotation.title = self.eventName
            annotation.coordinate = loc.location.coordinate
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if let loc = self.location {
            let annotation = MKPointAnnotation()
            annotation.title = self.eventName
            annotation.coordinate = loc.location.coordinate
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
