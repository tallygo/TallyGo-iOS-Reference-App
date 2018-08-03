//
//  DisplayWaypointsListViewController.swift
//  Reference App
//
//  Created by David Deller on 6/19/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class DisplayWaypointsListViewController: ExampleViewController {

    @IBAction func go(_ sender: Any) {
        getRoute()
    }
    
    // MARK: -
    
    func getRoute() {
        // Get these coordinates from your app, these are just a sample
        let waypoints: [TGWaypoint] = [
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944), address: nil, description: "Grauman's Chinese Theatre"),
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.07902875, longitude: -118.379441), address: nil, description: "Quarter point"),
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.0564995, longitude: -118.417938), address: nil, description: "Midpoint"),
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.03397025, longitude: -118.456435), address: nil, description: "Three-quarters point"),
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.011441, longitude: -118.494932), address: nil, description: "Santa Monica Pier"),
        ]
        
        let request = TGRouteRequest(waypoints: waypoints)
        
        TGNavigationService.route(for: request) { (response) in
            if let error = response.error {
                // handle error
                
                self.handleError(error)
                
            } else if let route = response.route {
                // do something with route
                
                self.showWaypointsList(route: route)
            }
        }
    }
    
    func showWaypointsList(route: TGRoute) {
        let viewController = TGWaypointsListViewController.create()
        viewController.route = route
        
        viewController.nextWaypoint = route.segments.first!.destinationWaypoint
        viewController.getCurrentLocationWaypoint = { () -> TGWaypoint in
            return route.segments.first!.originWaypoint
        }
        
        if let navigationController = navigationController {
            navigationController.navigationBar.isHidden = false
            navigationController.pushViewController(viewController, animated: true)
            
        } else {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pressDoneButton(_:)))
            present(viewController.embedInNavigationController(), animated: true, completion: nil)
        }
    }
    
    // This method isn't necessary if you're pushing it onto a UINavigationController
    @objc func pressDoneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
