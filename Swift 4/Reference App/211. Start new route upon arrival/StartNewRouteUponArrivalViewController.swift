//
//  AddWaypointDuringNavViewController.swift
//  Reference App
//
//  Created by David Deller on 8/2/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class StartNewRouteUponArrivalViewController: ExampleViewController {

    @IBAction func go(_ sender: Any) {
        TGDrivingSimulator.shared.startingCoordinate = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944) // Grauman's Chinese Theatre
        TGDrivingSimulator.shared.enabled = true
        
        // Get these coordinates from your app, these are just a sample
        let firstWaypoint = TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944)) // Grauman's Chinese Theatre
        let secondWaypoint = TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.108558, longitude: -118.336143)) // Hollywood Heritage Museum
        
        // Configure turn-by-turn navigation
        let config = TGTurnByTurnConfiguration()
        config.originWaypoint = firstWaypoint
        config.destinationWaypoint = secondWaypoint
        
        // Start navigation
        let viewController = TGTurnByTurnViewController.create(with: config)
        present(viewController, animated: true, completion: nil)
        
        var observer: Any?
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryRouteConcluded, object: nil, queue: nil) { (notification) in
            guard let routeSegment = notification.userInfo?[TGTelemetryUserInfo.routeSegment] as? TGRouteSegment else {
                return
            }
            
            // Check to make sure the driver arrived at the place we expected
            guard routeSegment.destinationWaypoint == secondWaypoint else {
                // If not, you probably want to handle this situation appropriately.
                // For this example, we'll log a message and return.
                NSLog("The driver isn't where we expected...")
                return
            }
            
            // Dismiss the existing turn-by-turn view controller
            self.dismiss(animated: true, completion: nil)
            
            // Configure a new turn-by-turn navigation session. This time, we are going the opposite direction.
            let config = TGTurnByTurnConfiguration()
            config.originWaypoint = secondWaypoint
            config.destinationWaypoint = firstWaypoint
            
            let viewController = TGTurnByTurnViewController.create(with: config)
            
            // Confirm with the driver that it's OK to proceed
            let alert = UIAlertController(title: "Proceeding to the next destination", message: config.destinationWaypoint!.addressDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                // Driver accepted, start the next session
                self.present(viewController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Stop Navigation", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            // Prevent this observer from executing again the next time the driver arrives
            NotificationCenter.default.removeObserver(observer!)
        }
    }

}
