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
    
    var userDefaults: UserDefaults = UserDefaults.standard
    var zipCode: String?
    var animalType: AnimalType = AnimalType.dog
    
    //Array of animals
    var animals: [Animal] = []
    var currentPage = 1
    var totalPages = 1
    var totalAnimal = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        //Fetch the users animal type and zip code
        fetchUserDefaults()
        //Initialize animal resource
        updateResource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        aminalResource?.loadIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Open setttings on first load
        if zipCode?.isEmpty ?? true {
            performSegue(withIdentifier: "segueToSettings", sender: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    @IBAction func unwindToMainViewController(_ sender: UIStoryboardSegue){
        //If the users changed their settings then update the resource
        if let vc = sender.source as? SettingsViewController, vc.isDirty {
            fetchUserDefaults()
            currentPage = 1
            updateResource()
            if tableView.numberOfRows(inSection: 0) > 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    //Takes the total count of animals minus the last response from the server to calculate what cells need to be updated
    func calculateIndexPathsToReload(from count: Int) -> [IndexPath] {
      let startIndex = animals.count - count
      let endIndex = startIndex + count
      return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    //Check to see if the cells that need to be reloaded are visible
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
      let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
      let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
      return Array(indexPathsIntersection)
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
        switch event {
        case .error:
            showAlertView(message: resource.latestError?.userMessage ?? "Networking Error")
            hideLoadingIndicator()
            break
        case .requested,
             .observerAdded:
            if currentPage == 1{
                showLoadingIndicator()
            }
            break
        case .newData,
             .notModified,
             .requestCancelled:
            hideLoadingIndicator()
            break
        }
        
        if resource.isUpToDate {
            hideLoadingIndicator()
        }
        if let response : GetAnimalsResponse = resource.typedContent() {
            if response.pagination.current_page == 1 {
                animals = []
                totalPages = response.pagination.total_pages
                totalAnimal = response.pagination.total_count
            }
            currentPage = response.pagination.current_page + 1
            animals.append(contentsOf: response.animals)
            if response.pagination.current_page > 1 {
                //Get the section that was loaded
                let newIndexPathsToReload = calculateIndexPathsToReload(from: response.animals.count)
                //Check if cells are visible
                let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
                tableView.reloadRows(at: indexPathsToReload, with: .automatic)
            }else{
                //If first page then reload table view
                tableView.reloadData()
            }
        }
    }
}

// MARK: - Private Methods
private extension MainViewController {
    //Check to see if the cell is outside of the current count of animals
    func isLoadingCell(for indexPath: IndexPath) -> Bool{
        return indexPath.row >= animals.count
    }
    
    func updateResource(){
        if let zipCode = zipCode, !zipCode.isEmpty {
            aminalResource = PetFinderApi.sharedInstance.getAnimals(type: animalType, zipCode: zipCode, page: currentPage)
        }
    }
    
    func showLoadingIndicator(){
        tableView.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        tableView.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    //Store user defaults in variable so we don't have to fetch them on ever new page load
    //Impoves performace
    func fetchUserDefaults(){
        if let type = userDefaults.string(forKey: "type"), !type.isEmpty, let animalType = AnimalType(rawValue: type) {
            self.animalType = animalType
        }
        if let zipCode = userDefaults.string(forKey: "zipCode"), !zipCode.isEmpty {
            self.zipCode = zipCode
        }
        
    }
    
    func showAlertView(message: String){
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)

    }

}
