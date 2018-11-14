//
//  MapViewController.swift
//  WeatherPM_2
//
//  Created by macuser on 14/11/2018.
//  Copyright © 2018 pawmat. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapOutlet: MKMapView!
    
    var lat : Double!
    var lon : Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapOutlet.setCenter(coordinates, animated: true)
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        mapOutlet.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapOutlet.removeAnnotations(mapOutlet.annotations)
        mapOutlet.addAnnotation(annotation)
    }

}
