//
//  AddWaypointDuringNavViewController.swift
//  Reference App
//
//  Created by David Deller on 8/2/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class AddWaypointDuringNavViewController: ExampleViewController {
    
    var timer: Timer?

    @IBAction func go(_ sender: Any) {
        TallyGo.simulatedCoordinate = CLLocationCoordinate2D(latitude: 34.0555, longitude: -118.417938) // Midpoint
        
        // Get these coordinates from your app, these are just a sample
        let waypoints: [TGWaypoint] = [
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.0555, longitude: -118.417938), address: nil, description: "Midpoint"),
            TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.011441, longitude: -118.494932), address: nil, description: "Santa Monica Pier")
        ]
        
        // Configure turn-by-turn navigation
        let config = TGTurnByTurnConfiguration()
        config.showsOriginIcon = false
        config.commencementSpeech = "Let's go!"
        config.proceedToRouteSpeech = "Please proceed to the route."
        config.arrivalSpeech = "You have arrived."
        
        config.routeRequest = TGRouteRequest(waypoints: waypoints)
        
        // Start navigation
        let viewController = TGTurnByTurnViewController.create(with: config)
        present(viewController, animated: true, completion: nil)
        
        // Wait 30 seconds after starting navigation before adding a waypoint.
        // This simulates a server request that might automatically initiate this kind of action based on a realtime event.
        // Instead of a timer, you would use your own custom networking code to initiate this part.
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false, block: { (_) in
            let waypointToAdd = TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944), address: nil, description: "Grauman's Chinese Theatre")
            
            viewController.add(waypointToAdd, toEnd: false, completion: { (_, _, error) in
                guard error == nil else {
                    NSLog("Failed to add waypoint: \(error!)")
                    return
                }
                
                // Inform the driver what is happening. This plays an audio cue, but you might also want to include a non-blocking visual cue.
                TGVoiceSynthesis.shared.say("A new delivery order has come in. You are being rerouted to \(waypointToAdd.addressDescription ?? "a new destination")")
            })
        })
    }

}
