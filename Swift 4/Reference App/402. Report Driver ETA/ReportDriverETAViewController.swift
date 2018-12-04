//
//  ReportDriverETAViewController.swift
//  Reference App
//
//  Created by David (work 2) on 5/2/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class ReportDriverETAViewController: ExampleViewController {

    @IBOutlet weak var serverURLLabel: UILabel!
    
    var turnByTurnViewController: TGTurnByTurnViewController?
    let temporaryID = UUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverURLLabel.text = "\(reportETAURL.scheme!)://\(reportETAURL.host!):\(reportETAURL.port!)"
    }
    
    @IBAction func go(_ sender: Any) {
        startTurnByTurn()
    }
    
    func startTurnByTurn() {
        TGDrivingSimulator.shared.startingCoordinate = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944) // Grauman's Chinese Theatre
        TGDrivingSimulator.shared.enabled = true
        
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
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TGTelemetryCurrentPointChange, object: nil, queue: nil) { (notification) in
            guard let newETA = notification.userInfo?[TGTelemetryUserInfo.ETA] as? Date else {
                return
            }
            
            self.reportETA(newETA)
        }
    }
    
    // You can change these configuration values to suit your needs.
    let reportETADeltaTrigger: TimeInterval = 60
    let reportETATimeTrigger: TimeInterval = (5 * 60)
    let reportETAURL = URL(string: "http://localhost:3200/drivers/eta")!
    let reportETAMethod = "PUT"
    
    // Keep track of when and what we last reported.
    var lastReportedETA: Date?
    var lastReportedETATime: Date?

    func reportETA(_ ETA: Date) {
        // We should only continue if we haven't reported yet, or if one of our triggers has been satisfied.
        guard (lastReportedETA == nil ||
            lastReportedETATime == nil ||
            abs(ETA.timeIntervalSince(lastReportedETA!)) > reportETADeltaTrigger ||
            Date().timeIntervalSince(lastReportedETATime!) > reportETATimeTrigger) else {
                
            return
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        // Collect the data we want to send
        let requestData = [
            "ETA": formatter.string(from: ETA),
        ]
        
        // Configure the request
        var request = URLRequest(url: reportETAURL)
        request.httpMethod = reportETAMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(temporaryID, forHTTPHeaderField: "X-Temporary-ID")
        request.httpBody = try! JSONEncoder().encode(requestData)
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error reporting ETA: \(error)")
                self.handleError(error, viewController: self.turnByTurnViewController)
                
            } else {
                // Optionally, you can do something with the successful response here.
            }
        }
        task.resume()
        
        // Remember that we did this
        lastReportedETA = ETA
        lastReportedETATime = Date()
    }

}
