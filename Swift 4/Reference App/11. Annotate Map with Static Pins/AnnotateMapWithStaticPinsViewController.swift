//
//  AnnotateMapWithStaticPinsViewController.swift
//  Reference App
//
//  Created by David Deller on 5/1/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class AnnotateMapWithStaticPinsViewController: ExampleViewController {

    @IBOutlet weak var mapView: TGMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.zoomLevel = 12
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944)
        
        annotateMap()
    }
    
    func annotateMap() {
        // Declare the marker "pin" and set its coordinates, title, and subtitle
        let pin = MGLPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944)
        pin.title = "Grauman's Chinese Theatre"
        pin.subtitle = "6925 Hollywood Blvd, Hollywood, CA"
        
        // Add marker "pin" to the map
        mapView.addAnnotation(pin)
    }

}
