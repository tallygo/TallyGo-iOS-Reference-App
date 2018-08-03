//
//  InsertMapViewWithoutStoryboardViewController.swift
//  Reference App
//
//  Created by David Deller on 5/1/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class InsertMapViewWithoutStoryboardViewController: ExampleViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Part 1: Initialize the view
        let mapView = TGMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.translatesAutoresizingMaskIntoConstraints = true
        
        // Part 2: Customize it to your liking
        mapView.tintColor = UIColor.green
        mapView.zoomLevel = 12
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: false)
        
        // Part 3: Add it to your existing view
        view.addSubview(mapView)
    }

}
