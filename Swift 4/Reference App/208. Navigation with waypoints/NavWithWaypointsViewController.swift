//
//  NavWithWaypointsViewController.swift
//  Reference App
//
//  Created by David Deller on 8/2/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class NavWithWaypointsViewController: ExampleViewController {

    @IBAction func go(_ sender: Any) {
        TallyGo.simulatedCoordinate = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944) // Grauman's Chinese Theatre
        
        // Get these coordinates from your app, these are just a sample
        let waypoints: [TGWaypoint] = [
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944), address: nil, description: "Grauman's Chinese Theatre"),
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.07902875, longitude: -118.379441), address: nil, description: "Quarter point"),
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.0564995, longitude: -118.417938), address: nil, description: "Midpoint"),
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.03397025, longitude: -118.456435), address: nil, description: "Three-quarters point"),
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.011441, longitude: -118.494932), address: nil, description: "Santa Monica Pier"),
        ]
        
        // Configure turn-by-turn navigation
        let config = TGTurnByTurnConfiguration()
        config.showsOriginIcon = false
        config.commencementSpeech = "Let's go!"
        config.proceedToRouteSpeech = "Please proceed to the route."
        config.arrivalSpeech = "You have arrived."
        
        config.routeRequest = TGRouteRequest(waypoints: waypoints)
        
        // Display it
        let viewController = TGPreviewViewController.create(with: config).embedInNavigationController()
        present(viewController, animated: true, completion: nil)
    }

}
