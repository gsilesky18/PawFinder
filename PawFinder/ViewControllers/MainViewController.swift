//
//  MainViewController.swift
//  PawFinder
//
//  Created by Greg Silesky on 10/11/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import UIKit
import Siesta

class MainViewController: UIViewController {
    
    //Loading indicator
    var statusOverlay = ResourceStatusOverlay()
    
    //Resource used to retrieve data from PetFinder
    var aminalResource: Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            oldValue?.cancelLoadIfUnobserved(afterDelay: 0.1)

            aminalResource?.addObserver(self).addObserver(statusOverlay, owner: self).loadIfNeeded()

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup Siesta overlay
        statusOverlay.embed(in: self)
        statusOverlay.displayPriority = [.loading, .anyData, .error]
        
        aminalResource = PetFinderApi.sharedInstance.getAnimals()
    }
    
    override func viewDidLayoutSubviews() {
        //Set overlay to cover view
        statusOverlay.positionToCover(view.bounds, inView: view)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Resource observer
extension MainViewController: ResourceObserver {
    
    //Observer for when the resource status changes
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        
        if let response : GetAnimalsResponse = resource.typedContent() {
            print(response)
        }
    }
}
