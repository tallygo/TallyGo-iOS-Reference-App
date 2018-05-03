//
//  DisplaySearchViewController.swift
//  Reference App
//
//  Created by David Deller on 5/1/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class DisplaySearchViewController: OutputViewController, TGSearchViewControllerDelegate {

    @IBAction func go(_ sender: Any) {
        showSearch()
    }
    
    // MARK: -
    
    var searchNavController: UINavigationController?
    
    func showSearch() {
        let searchVC = TGSearchViewController.create()
        searchVC.delegate = self
        
        let navController = searchVC.embedInNavigationController()
        present(navController, animated: true)
        
        searchNavController = navController
    }
    
    let exampleCoordinate = CLLocationCoordinate2D(latitude: 34.101558, longitude: -118.340944) // Grauman's Chinese Theatre
    let exampleSearchExtent = TGSearchExtent(southwestCoordinate: CLLocationCoordinate2D(latitude: 34.055534, longitude: -118.37313),
                                             northeastCoordinate: CLLocationCoordinate2D(latitude: 34.1504, longitude: -118.308757))
    
    func coordinate(for requestType: TGSearchViewControllerRequestType) -> CLLocationCoordinate2D {
        return exampleCoordinate
        
        // Note: If you have a TGMapView or MGLMapView, you can get the current location like this:
        //return mapView.centerCoordinate
    }
    
    func searchExtent(for requestType: TGSearchViewControllerRequestType) -> TGSearchExtent {
        return exampleSearchExtent
        
        // Note: If you have a TGMapView or MGLMapView, you can get the current bounds like this:
        //return TGSearchExtent(coordinateBounds: mapView.visibleCoordinateBounds)
    }
    
    func didSelect(_ searchResult: TGSearchResult) {
        searchNavController?.dismiss(animated: true)
        
        // Do something with the selected search result
        
        handleOutput(searchResult)
    }

}
