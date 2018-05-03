//
//  DisplayDriverReportedLocationViewController.swift
//  Reference App
//
//  Created by David (work 2) on 5/2/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit
import Starscream

class DisplayDriverReportedLocationViewController: ExampleViewController, MGLMapViewDelegate {
    
    enum EventType: String {
        case currentLocation = "current_location"
        case ETA = "eta"
    }

    @IBOutlet weak var mapView: TGMapView!
    
    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupWebSocket()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        teardownWebSocket()
    }

    var socket: WebSocket?
    
    func setupWebSocket() {
        let socket = WebSocket(url: URL(string: "ws://localhost:3200/")!)
        
        socket.onConnect = {
            print("WebSocket is connected")
        }
        
        socket.onDisconnect = { (error: Error?) in
            print("WebSocket is disconnected: \(error?.localizedDescription ?? "")")
        }
        
        socket.onText = { (text: String) in
            do {
                var data = try JSONSerialization.jsonObject(with: text.data(using: .utf8)!, options: []) as! Dictionary<String, Any>
                
                guard let eventTypeString = data["event_type"] as? String,
                    let eventType = EventType(rawValue: eventTypeString),
                    let payload = data["payload"] as? Dictionary<String, Any> else {
                        
                        NSLog("JSON not in expected format: \(text)")
                        return
                }
                
                self.handleEvent(eventType: eventType, payload: payload)
                
            } catch (let error) {
                NSLog("Error parsing JSON from WebSocket: \(error), JSON: \(text)")
            }
        }
        
        socket.connect()
        
        self.socket = socket
    }

    func teardownWebSocket() {
        socket?.disconnect()
    }

    func handleEvent(eventType: EventType, payload: Dictionary<String, Any>) {
        switch eventType {
        case .currentLocation:
            guard let latitude = payload["latitude"] as? Double, let longitude = payload["longitude"] as? Double else {
                NSLog("Payload not in expected format: \(payload)")
                return
            }
            
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.handleLocationEvent(location: location)
            
        case .ETA:
            guard let ETAString = payload["ETA"] as? String else {
                NSLog("Payload not in expected format: \(payload)")
                return
            }
            
            let formatter = ISO8601DateFormatter()
            guard let ETA = formatter.date(from: ETAString) else {
                NSLog("Date not in expected format: \(ETAString)")
                return
            }
            
            self.handleETAEvent(ETA: ETA)
        }
    }
    
    var driverAnnotation: DriverAnnotation?
    
    func handleLocationEvent(location: CLLocationCoordinate2D) {
        if let driverAnnotation = self.driverAnnotation {
            mapView.removeAnnotation(driverAnnotation)
        }
        
        let driverAnnotation = DriverAnnotation(location: location)
        mapView.addAnnotation(driverAnnotation)
        self.driverAnnotation = driverAnnotation
        
        mapView.setCenter(location, zoomLevel: 15, animated: true)
    }
    
    func handleETAEvent(ETA: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .long
        
        let ETAString = formatter.string(from: ETA)
        self.navigationItem.title = "ETA: \(ETAString)"
    }

    // MARK: - MGLMapViewDelegate
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        let ID = "driver annotation image"
        if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: ID) {
            return annotationImage
        } else {
            let image = TallyGoStyleKit.imageOfGenericPlaceIcon()!
            
            return MGLAnnotationImage(image: image, reuseIdentifier: ID)
        }
    }

}

// MARK: -

class DriverAnnotation: NSObject, MGLAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    var title: String? {
        return "Driver Location"
    }
    
    init(location: CLLocationCoordinate2D) {
        coordinate = location
    }
    
}

