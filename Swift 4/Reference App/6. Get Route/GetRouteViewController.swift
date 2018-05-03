//
//  GetRouteViewController.swift
//  Reference App
//
//  Created by David Deller on 5/1/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class GetRouteViewController: OutputViewController {
    
    @IBAction func go(_ sender: Any) {
        getRoute()
    }
    
    // MARK: -

    func getRoute() {
        // Get these coordinates from your app, these are just a sample
        let origin = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944) // Grauman's Chinese Theatre
        let destination = CLLocationCoordinate2D(latitude: 34.011441, longitude: -118.494932) // Santa Monica Pier
        
        let coords: [CLLocationCoordinate2D] = [origin, destination]
        
        let request = TGRouteRequest(coords: coords)
        
        TGNavigationService.route(for: request) { (response) in
            if let error = response.error {
                // handle error
                
                self.handleError(error)
                
            } else if let route = response.route {
                // do something with route
                
                self.handleOutput(route)
            }
        }
    }

}
