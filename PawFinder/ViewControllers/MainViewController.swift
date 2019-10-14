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
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    //Array of animals
    var animals: [Animal] = []{
        didSet{
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup Siesta overlay
        statusOverlay.embed(in: self)
        statusOverlay.displayPriority = [.loading, .anyData, .error]
        
        aminalResource = PetFinderApi.sharedInstance.getAnimals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        aminalResource?.loadIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        //Set overlay to cover view
        statusOverlay.positionToCover(view.bounds, inView: view)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToDetail"{
            if let vc = segue.destination as? DetailTableViewController, let cell = sender as? AnimalTableViewCell {
                //Pass selected animal to detail view controller
                vc.animal = cell.animal
            }
        }
    }

}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AnimalTableViewCell.kAnimalTableViewCell, for: indexPath) as? AnimalTableViewCell else {
            return UITableViewCell()
        }
        cell.animal = animals[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Resource observer
extension MainViewController: ResourceObserver {
    
    //Observer for when the resource state changes
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        
        if let response : GetAnimalsResponse = resource.typedContent() {
            animals = response.animals
        }
    }
}
