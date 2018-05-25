//
//  DisplayDriverMotionViewController.swift
//  Reference App
//
//  Created by David Deller on 5/25/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit
import Starscream

class DisplayDriverMotionViewController: ExampleViewController, MGLMapViewDelegate {
    
    enum EventType: String {
        case motion = "motion"
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
        case .motion:
            guard let points = payload["points"] as? [[Double]], let timeInterval = payload["timeInterval"] as? TimeInterval else {
                NSLog("Payload not in expected format: \(payload)")
                return
            }
            
            let locations = points.compactMap { (coordinatePair) -> CLLocationCoordinate2D? in
                if let latitude = coordinatePair.first, let longitude = coordinatePair.last {
                    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                } else {
                    return nil
                }
            }
            
            self.handleMotionEvent(locations: locations, timeInterval: timeInterval)
        }
    }
    
    var driverAnnotation: MGLPointAnnotation = MGLPointAnnotation()
    var animator: UIViewPropertyAnimator?
    
    func handleMotionEvent(locations: [CLLocationCoordinate2D], timeInterval: TimeInterval) {
        // We need at least one location
        guard let firstLocation = locations.first else {
            return
        }
        
        // Stop any previous animation that may still be running
        self.animator?.stopAnimation(true)
        self.animator = nil
        
        // Add the annotation to the map, if it hasn't been already
        if mapView.annotations == nil || !(mapView.annotations! as NSArray).contains(driverAnnotation) {
            mapView.addAnnotation(driverAnnotation)
        }
        
        // Zoom/pan the map to fit all of the coordinates, so the marker won't go off-screen
        mapView.setVisibleCoordinates(locations, count: UInt(locations.count), edgePadding: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30), animated: false)
        
        // Start out by jumping immediately to the first coordinate
        driverAnnotation.coordinate = firstLocation
        
        var locationsAfterFirst = locations
        locationsAfterFirst.removeFirst()
        
        // We need more coordinates if we're going to animate them
        guard locationsAfterFirst.count > 0 else {
            return
        }
        
        let animator = UIViewPropertyAnimator(duration: timeInterval, timingParameters: UICubicTimingParameters(animationCurve: .linear))
        let eachKeyframePercent: Double = (timeInterval / Double(locationsAfterFirst.count))
        var index = 0
        
        // Loop through each of the coordinates (besides the first, which we already jumped to) and animate each of them in sequence
        locationsAfterFirst.forEach { (location) in
            animator.addAnimations({
                self.driverAnnotation.coordinate = location
                
            }, delayFactor: (CGFloat(index) * CGFloat(eachKeyframePercent)))
            
            index += 1
        }
        
        // Start the animation
        animator.startAnimation()
        
        // Save the animator for later, in case we need to interrupt it when a new one is ready
        self.animator = animator
    }

    // MARK: - MGLMapViewDelegate
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        let ID = "driver annotation view"
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ID) {
            return annotationView
        } else {
            let view = MGLAnnotationView(annotation: annotation, reuseIdentifier: ID)
            
            let imageView = UIImageView(image: TallyGoStyleKit.imageOfGenericPlaceIcon()!)
            view.bounds = imageView.frame
            view.addSubview(imageView)
            
            return view
        }
    }

}

