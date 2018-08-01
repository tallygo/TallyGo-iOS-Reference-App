//
//  InsertMapViewWithStoryboardViewController.swift
//  Reference App
//
//  Created by David Deller on 5/1/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class InsertMapViewWithStoryboardViewController: ExampleViewController {

    @IBOutlet weak var mapView: TGMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Part 2: Customize it to your liking
        mapView.tintColor = UIColor.green
        mapView.zoomLevel = 12
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: false)
    }

}
