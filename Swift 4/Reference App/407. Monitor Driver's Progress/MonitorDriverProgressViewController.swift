//
//  ReportDriverCurrentLocationViewController.swift
//  Reference App
//
//  Created by David Deller on 5/2/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class MonitorDriverProgressViewController: ExampleViewController {
    
    var turnByTurnViewController: TGTurnByTurnViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func go(_ sender: Any) {
        startTurnByTurn()
    }
    
    func startTurnByTurn() {
        TallyGo.simulatedCoordinate = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944) // Grauman's Chinese Theatre
        
        // Increase the simulated driving speed above realistic levels so that we can see the console messages more quickly
        TallyGo.simulatedCitySpeed = 200 // meters per second
        TallyGo.simulatedHighwaySpeed = 200 // meters per second
        
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
        
        // If you’d rather skip the preview and jump straight into directions, you can do that:
        let viewController = TGTurnByTurnViewController.create(with: config)
        present(viewController, animated: true, completion: nil)
        
        turnByTurnViewController = viewController
        setupMonitoring()
    }
    
    func setupMonitoring() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryInitialized, object: nil, queue: nil) { (notification) in
            guard let route = notification.userInfo?[TGTelemetryUserInfo.route] as? TGRoute,
                let routeSegment = notification.userInfo?[TGTelemetryUserInfo.routeSegment] as? TGRouteSegment else {
                    return
            }
            
            NSLog("Turn-by-turn navigation status: initialized for route: \(route) starting at: \(routeSegment.originWaypoint.addressDescription ?? "unknown")")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryStarted, object: nil, queue: nil) { (notification) in
            NSLog("Turn-by-turn navigation status: started navigating")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryProceedingToRoute, object: nil, queue: nil) { (notification) in
            NSLog("Turn-by-turn navigation status: driver is proceeding to route")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryCurrentPointChange, object: nil, queue: nil) { (notification) in
            guard let fromPoint = notification.userInfo?[TGTelemetryUserInfo.fromPoint] as? TGPoint,
                let toPoint = notification.userInfo?[TGTelemetryUserInfo.toPoint] as? TGPoint,
                let ETA = notification.userInfo?[TGTelemetryUserInfo.ETA] as? Date else {
                    return
            }
            
            NSLog("Turn-by-turn navigation status: driver has moved from point \(fromPoint.coordinate.latitude),\(fromPoint.coordinate.longitude) to point \(toPoint.coordinate.latitude),\(toPoint.coordinate.longitude) with ETA: \(ETA)")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryNextTurnChange, object: nil, queue: nil) { (notification) in
            guard let turnPoint = notification.userInfo?[TGTelemetryUserInfo.turnPoint] as? TGPoint,
                let turn = turnPoint.turn else {
                    return
            }
            
            NSLog("Turn-by-turn navigation status: currently displayed upcoming turn: \(turn.direction.rawValue) on to \(turn.street?.name ?? "unknown")")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryOffRoute, object: nil, queue: nil) { (notification) in
            NSLog("Turn-by-turn navigation status: driver is off-route")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryRerouting, object: nil, queue: nil) { (notification) in
            NSLog("Turn-by-turn navigation status: driver is rerouting")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryRerouted, object: nil, queue: nil) { (notification) in
            NSLog("Turn-by-turn navigation status: driver has rerouted")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryCancelled, object: nil, queue: nil) { (notification) in
            NSLog("Turn-by-turn navigation status: driver cancelled navigation")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetrySegmentConcluded, object: nil, queue: nil) { (notification) in
            guard let route = notification.userInfo?[TGTelemetryUserInfo.route] as? TGRoute,
                let routeSegment = notification.userInfo?[TGTelemetryUserInfo.routeSegment] as? TGRouteSegment else {
                    return
            }
            
            NSLog("Turn-by-turn navigation status: driver has arrived at a destination: '\(routeSegment.destinationWaypoint.addressDescription ?? "unknown address")' in route: \(route)")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetrySegmentAdvanced, object: nil, queue: nil) { (notification) in
            guard let route = notification.userInfo?[TGTelemetryUserInfo.route] as? TGRoute,
                let routeSegment = notification.userInfo?[TGTelemetryUserInfo.routeSegment] as? TGRouteSegment else {
                    return
            }
            
            NSLog("Turn-by-turn navigation status: driver has advanced to the next segment: '\(routeSegment.destinationWaypoint.addressDescription ?? "unknown address")' in route: \(route)")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryRouteConcluded, object: nil, queue: nil) { (notification) in
            guard let route = notification.userInfo?[TGTelemetryUserInfo.route] as? TGRoute,
                let routeSegment = notification.userInfo?[TGTelemetryUserInfo.routeSegment] as? TGRouteSegment else {
                    return
            }
            
            NSLog("Turn-by-turn navigation status: driver has arrived at final destination: '\(routeSegment.destinationWaypoint.addressDescription ?? "unknown address")' in route: \(route)")
        }
    }
    
}
