//
//  ReportDriverMotionViewController.swift
//  Reference App
//
//  Created by David Deller on 5/23/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class ReportDriverMotionViewController: ExampleViewController {

    @IBOutlet weak var serverURLLabel: UILabel!
    
    var turnByTurnViewController: TGTurnByTurnViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverURLLabel.text = "\(reportMotionURL.scheme!)://\(reportMotionURL.host!):\(reportMotionURL.port!)"
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
            
            self.collectLocation(newPoint)
        }
    }
    
    // You can change these configuration values to suit your needs.
    let reportMotionURL = URL(string: "http://localhost:3200/drivers/motion")!
    let reportMotionMethod = "POST"
    
    let collectInterval: TimeInterval = 30
    
    var collectBeginTime: Date?
    var collectedLocations: [TGPoint] = []
    
    func collectLocation(_ point: TGPoint) {
        if collectBeginTime == nil {
            collectBeginTime = Date()
            
        } else if Date().timeIntervalSince(collectBeginTime!) >= collectInterval {
            reportMotion()
            collectedLocations = []
            collectBeginTime = Date()
        }
        
        collectedLocations.append(point)
    }
    
    func reportMotion() {
        let requestData: [String: Any] = [
            "id": UUID().uuidString,
            "points": collectedLocations.map({ (point) -> [CLLocationDegrees] in
                return [point.coordinate.latitude, point.coordinate.longitude]
            }),
            "timeInterval": collectInterval,
        ]
        
        // Configure the request
        var request = URLRequest(url: reportMotionURL)
        request.httpMethod = reportMotionMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: requestData, options: [])

        // Send the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error reporting driver motion: \(error)")
                self.handleError(error, viewController: self.turnByTurnViewController)

            } else {
                // Optionally, you can do something with the successful response here.
            }
        }
        task.resume()
    }

}
