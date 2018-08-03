//
//  ReportDriverCurrentLocationViewController.swift
//  Reference App
//
//  Created by David (work 2) on 5/2/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class ReportDriverCurrentLocationViewController: ExampleViewController {

    @IBOutlet weak var serverURLLabel: UILabel!
    
    var turnByTurnViewController: TGTurnByTurnViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverURLLabel.text = "\(reportLocationURL.scheme!)://\(reportLocationURL.host!):\(reportLocationURL.port!)"
    }
    
    @IBAction func go(_ sender: Any) {
        startTurnByTurn()
    }
    
    func startTurnByTurn() {
        TallyGo.simulatedCoordinate = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944) // Grauman's Chinese Theatre
        
        // Get these coordinates from your app, these are just a sample
        let origin = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944) // Grauman's Chinese Theatre
        let destination = CLLocationCoordinate2D(latitude: 34.011441, longitude: -118.494932) // Santa Monica Pier
        
        // Configure turn-by-turn navigation
        let config = TGTurnByTurnConfiguration()
        config.showsOriginIcon = false
        config.origin = origin
        config.destination = destination
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
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryCurrentPointChange, object: nil, queue: nil) { (notification) in
            guard let newPoint = notification.userInfo?[TGTelemetryUserInfo.toPoint] as? TGPoint else {
                return
            }
            
            self.reportLocation(newPoint)
        }
    }
    
    // You can change these configuration values to suit your needs.
    let reportLocationPointTrigger: CLLocationDistance = 100
    let reportLocationTimeTrigger: TimeInterval = 60
    let reportLocationURL = URL(string: "http://localhost:3200/drivers/current_location")!
    let reportLocationMethod = "PUT"
    
    // Keep track of when and what we last reported.
    var lastReportedLocationPoint: TGPoint?
    var lastReportedLocationTime: Date?
    
    func reportLocation(_ point: TGPoint) {
        // We should only continue if we haven't reported yet, or if one of our triggers has been satisfied.
        guard (lastReportedLocationPoint == nil ||
            lastReportedLocationTime == nil ||
            TGLocationCoordinateDistanceFromCoordinate(lastReportedLocationPoint!.coordinate, point.coordinate) > reportLocationPointTrigger ||
            Date().timeIntervalSince(lastReportedLocationTime!) > reportLocationTimeTrigger) else {
                
            return
        }
        
        // Collect the data we want to send
        let requestData = [
            "latitude": point.coordinate.latitude,
            "longitude": point.coordinate.longitude,
        ]
        
        // Configure the request
        var request = URLRequest(url: reportLocationURL)
        request.httpMethod = reportLocationMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(requestData)
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error reporting current location: \(error)")
                self.handleError(error, viewController: self.turnByTurnViewController)
                
            } else {
                // Optionally, you can do something with the successful response here.
            }
        }
        task.resume()
        
        // Remember that we did this
        lastReportedLocationPoint = point
        lastReportedLocationTime = Date()
    }
    
}
