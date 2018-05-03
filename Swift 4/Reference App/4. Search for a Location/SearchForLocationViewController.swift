//
//  SearchForLocationViewController.swift
//  Reference App
//
//  Created by David Deller on 5/1/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class SearchForLocationViewController: InputOutputViewController {
    
    override func handleInput(_ input: String) {
        search(using: input)
    }

    func search(using address: String) {
        let currentLocation = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944) // Grauman's Chinese Theatre
        
        let request = TGSearchRequest(singleLine: address, location: currentLocation, searchExtent: nil, suggestionKey: nil)
        
        TGFindService.search(with: request) { (response) in
            let results = response.results
            // do something with results
            
            self.handleOutput(results)
        }
    }


}
