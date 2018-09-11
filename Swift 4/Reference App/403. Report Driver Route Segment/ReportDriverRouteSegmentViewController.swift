//
//  ReportDriverRouteSegmentViewController.swift
//  Reference App
//
//  Created by David (work 2) on 5/2/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class ReportDriverRouteSegmentViewController: ExampleViewController {

    @IBOutlet weak var serverURLLabel: UILabel!
    
    var turnByTurnViewController: TGTurnByTurnViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverURLLabel.text = "\(reportRouteSegmentURL.scheme!)://\(reportRouteSegmentURL.host!):\(reportRouteSegmentURL.port!)"
    }
    
    @IBAction func go(_ sender: Any) {
        startTurnByTurn()
    }
    
    func startTurnByTurn() {
        TallyGo.simulatedCoordinate = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944) // Grauman's Chinese Theatre
        
        // Get these coordinates from your app, these are just a sample
        let origin = TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944)) // Grauman's Chinese Theatre
        let destination = TGWaypoint(coordinate: CLLocationCoordinate2D(latitude: 34.011441, longitude: -118.494932)) // Santa Monica Pier
        
        // Configure turn-by-turn navigation
        let config = TGTurnByTurnConfiguration()
        config.showsOriginIcon = false
        config.originWaypoint = origin
        config.destinationWaypoint = destination
        config.commencementSpeech = "Let's go!"
        config.proceedToRouteSpeech = "Please proceed to the route."
        config.arrivalSpeech = "You have arrived."
        
        // If you’d rather skip the preview and jump straight into directions, you can do that:
        let viewController = TGTurnByTurnViewController.create(with: config)
        present(viewController, animated: true, completion: nil)
        
        turnByTurnViewController = viewController
        setupReporting()
    }
    
    func setupReporting() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryInitialized, object: nil, queue: nil) { (notification) in
            guard let newRouteSegment = notification.userInfo?[TGTelemetryUserInfo.routeSegment] as? TGRouteSegment else {
                return
            }
            
            self.reportRouteSegment(newRouteSegment)
        }
    }
    
    // You can change these configuration values to suit your needs.
    let reportRouteSegmentURL = URL(string: "http://localhost:3200/drivers/route_segment")!
    let reportRouteSegmentMethod = "PUT"
    
    // Keep track of when and what we last reported.
    var lastReportedRouteSegment: TGRouteSegment?

    func reportRouteSegment(_ routeSegment: TGRouteSegment) {
        // Only report when the route segment changes
        guard routeSegment != lastReportedRouteSegment else {
            return
        }
        
        // Configure the request
        var request = URLRequest(url: reportRouteSegmentURL)
        request.httpMethod = reportRouteSegmentMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: routeSegment.dictionary, options: [])
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error reporting route segment: \(error)")
                self.handleError(error, viewController: self.turnByTurnViewController)
                
            } else {
                // Optionally, you can do something with the successful response here.
            }
        }
        task.resume()
        
        lastReportedRouteSegment = routeSegment
    }

}
