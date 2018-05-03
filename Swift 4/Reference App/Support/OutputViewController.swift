//
//  ModalOutputViewController.swift
//  Reference App
//
//  Created by David Deller on 5/1/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class OutputViewController: ExampleViewController {
    
    @IBOutlet weak var outputView: UITextView!
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outputView.layer.borderWidth = 0.5
        outputView.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
        outputView.layer.cornerRadius = 4
    }
    
    // MARK: -
    
    func handleOutput(_ output: Any) {
        if let location = output as? CLLocationCoordinate2D {
            printOutput("\(location.latitude),\(location.longitude)")
            
        } else if let searchResults = output as? [TGSearchResult] {
            let resultsText = (searchResults.map { (searchResult) -> String in
                return searchResult.placeAddress ?? ""
                
            } as NSArray).componentsJoined(by: "\n")
            
            printOutput(resultsText)
            
        } else if let searchResult = output as? TGSearchResult {
            let resultText = searchResult.placeAddress ?? ""
            
            printOutput(resultText)
            
        } else if let route = output as? TGRoute {
            let routeText: String = (route.segments.map({ (segment) -> String in
                return (segment.points.filter({ (point) -> Bool in
                    return (point.turn != nil)
                }).map({ (point) -> String in
                    return "\(point.turn!.direction.rawValue) on \(point.turn!.street?.name ?? "")"
                }) as NSArray).componentsJoined(by: "\n")
            }) as NSArray).componentsJoined(by: "\n")
            
            printOutput(routeText)
            
        } else {
            handleError(title: "Unable to handle output format")
        }
    }
    
    // MARK: -
    
    func clearOutput() {
        outputView.text = ""
    }
    
    func printOutput(_ output: String?) {
        if let output = output {
            outputView.text = output
        } else {
            clearOutput()
        }
    }

}
