//
//  CreateMapVCViewController.swift
//  Reference App
//
//  Created by David Deller on 5/1/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit
import TallyGoKit

class CreateMapVCViewController: ExampleViewController {

    @IBAction func go(_ sender: Any) {
        showMapVC()
    }
    
    // MARK: -
    
    var menuViewController: UIViewController {
        let alert = UIAlertController(title: "This is where your custom menu would go.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Exit", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        return alert
    }
    
    func showMapVC() {
        let mapViewController = TGMapViewController.create()
        mapViewController.onSelectMenuButton = {
            mapViewController.present(self.menuViewController, animated: true)
        }
        
        present(mapViewController.embedInNavigationController(), animated: true)
    }

}
