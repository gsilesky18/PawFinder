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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Resource used to retrieve data from PetFinder
    var aminalResource: Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            oldValue?.cancelLoadIfUnobserved(afterDelay: 0.1)

            aminalResource?.addObserver(self).loadIfNeeded()
        }
    }
    
    //Array of animals
    var animals: [Animal] = []
    var currentPage = 1
    var currentCount = 0
    var totalPages = 1
    var totalAnimal = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        //Update UI to show loading indicator
        tableView.isHidden = true
        activityIndicator.startAnimating()
        //Initialize animal resource
        updateResource()
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
        return totalAnimal
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AnimalTableViewCell.kAnimalTableViewCell, for: indexPath) as? AnimalTableViewCell else {
            return UITableViewCell()
        }
        if isLoadingCell(for: indexPath){
            cell.animal = nil
        }else{
            cell.animal = animals[indexPath.row]
        }
        
        return cell
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension MainViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell){
            updateResource()
        }
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
        if case .newData = event {
            if let response : GetAnimalsResponse = resource.typedContent() {
                currentPage += 1
                totalPages = response.pagination.total_pages
                totalAnimal = response.pagination.total_count
                animals.append(contentsOf: response.animals)
                if response.pagination.current_page > 1 {
                    //Get the section that was loaded
                    let newIndexPathsToReload = calculateIndexPathsToReload(from: response.animals.count)
                    //Check if cells are visible
                    let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
                    tableView.reloadRows(at: indexPathsToReload, with: .automatic)
                }else{
                    //If first page then reload table view
                    tableView.isHidden = false
                    activityIndicator.stopAnimating()
                    tableView.reloadData()
                }
            }
        }

    }
}

// MARK: - Private Methods
private extension MainViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool{
        return indexPath.row >= animals.count
    }
    
    func updateResource(){
        aminalResource = PetFinderApi.sharedInstance.getAnimals(type: "dog", zip: 55437, page: currentPage)
    }
    
    func calculateIndexPathsToReload(from count: Int) -> [IndexPath] {
      let startIndex = animals.count - count
      let endIndex = startIndex + count
      return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
      let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
      let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
      return Array(indexPathsIntersection)
    }

}
