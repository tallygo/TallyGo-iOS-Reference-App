//
//  ExampleViewController.swift
//  Reference App
//
//  Created by David Deller on 5/1/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {

    func handleError(_ error: Error, viewController: UIViewController? = nil) {
        let error = error as NSError
        
        let title = error.localizedDescription
        let message = "This error alert is implemented by the Reference App, not the TallyGo SDK. The method is named handleError(). You should provide your own error handling instead."
        
        handleError(title: title, message: message, viewController: viewController)
    }
    
    func handleError(title: String, message: String? = nil, viewController: UIViewController? = nil) {
        let viewController = viewController ?? self
        
        guard viewController.presentedViewController == nil else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }

}
