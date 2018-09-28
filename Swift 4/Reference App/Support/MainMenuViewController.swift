//
//  MainMenuViewController.swift
//  Reference App
//
//  Created by David Deller on 4/30/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class MainMenuViewController: UITableViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Clean up by resetting any settings from examples back to defaults
        TallyGo.simulatedCoordinate = kCLLocationCoordinate2DInvalid
    }
    
}
