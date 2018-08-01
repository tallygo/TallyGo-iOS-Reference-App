//
//  GetNavWithPreviewViewController.swift
//  Reference App
//
//  Created by David Deller on 4/30/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class GetNavWithPreviewViewController: ExampleViewController {
    
    @IBAction func go(_ sender: Any) {
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
        
        // Display it
        let viewController = TGPreviewViewController.create(with: config).embedInNavigationController()
        present(viewController, animated: true, completion: nil)
    }
    

}
