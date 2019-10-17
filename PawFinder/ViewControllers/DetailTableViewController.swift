//
//  DetailTableViewController.swift
//  PawFinder
//
//  Created by Greg Silesky on 10/13/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import UIKit
import Siesta

class DetailTableViewController: UITableViewController {

    @IBOutlet weak var remoteImageView: RemoteImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageAndBreedLabel: UILabel!
    @IBOutlet weak var primaryBreedLabel: UILabel!
    @IBOutlet weak var secondaryBreedLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var coatLabel: UILabel!
    @IBOutlet weak var spayedNeuteredLabel: UILabel!
    @IBOutlet weak var shotsUpToDateLabel: UILabel!
    @IBOutlet weak var houseTrainedLabel: UILabel!
    @IBOutlet weak var specialNeedsLabel: UILabel!
    @IBOutlet weak var goodWithKidsLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    
    //Animal is passed from main view controller
    var animal: Animal?
    
    //Sections in table view
    enum TableSections: Int{
        case Photo = 0, Name, Breed, Spacer1, PhysicalCharacteristics, Spacer2, Health, Spacer3, BehavioralCharacteristics, Spacer4, Contact, Spacer5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Update view with animal details
        if let animal = animal {
            if let photo = animal.photos.first?.full {
                remoteImageView.imageURL = photo
            }
            
            title = animal.name.capitalized
            nameLabel.text = animal.name.capitalized
            
            if let primaryBreed = animal.breeds.primary {
                ageAndBreedLabel.text = "\(animal.age) - \(primaryBreed)"
                primaryBreedLabel.text = "Primary - \(primaryBreed)"
            }else{
                ageAndBreedLabel.text = "\(animal.age)"
                primaryBreedLabel.text = nil
            }
            if let secondaryBreed = animal.breeds.secondary {
                secondaryBreedLabel.text = "Secondary - \(secondaryBreed)"
            }else{
                secondaryBreedLabel.text = nil
            }
            
            sizeLabel.text = "Size - \(animal.size)"
            genderLabel.text = "Gender - \(animal.gender)"
            ageLabel.text = "Age - \(animal.age)"
            if let coat = animal.coat {
              coatLabel.text = "Coat - \(coat)"
            }else{
                coatLabel.text = nil
            }
            spayedNeuteredLabel.text = "Spayed/Neutered - \(animal.attributes.spayed_neutered ? "Yes" : "No")"
            shotsUpToDateLabel.text = "Shots Up to Date - \(animal.attributes.shots_current ? "Yes" : "No")"
            houseTrainedLabel.text = "House Trained - \(animal.attributes.house_trained ? "Yes" : "No")"
            specialNeedsLabel.text = "Special Needs - \(animal.attributes.special_needs ? "Yes" : "No")"
            if let goodWKids = animal.environment.children {
                goodWithKidsLabel.text = "Good with Kids - \(goodWKids ? "Yes" : "No")"
            }else{
               goodWithKidsLabel.text = nil
            }
            
            if let email = animal.contact.email {
                emailButton.setTitle(email, for: .normal)
            }
            
            if let phone = animal.contact.phone {
                phoneButton.setTitle(phone, for: .normal)
            }
            
            tableView.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 12
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TableSections.Photo.rawValue:
            if animal?.photos.count ?? 0 > 0{
                return 1
            }
            return 0
        case TableSections.Name.rawValue:
            return 1
        case TableSections.Breed.rawValue:
            if animal?.breeds.mixed ?? false {
                return 3
            }
            if animal?.breeds.primary != nil {
                return 2
            }
            return 0
        case TableSections.Spacer1.rawValue:
            return 1
        case TableSections.PhysicalCharacteristics.rawValue:
            if animal?.coat != nil{
                return 5
            }
            return 4
        case TableSections.Spacer2.rawValue:
            return 1
        case TableSections.Health.rawValue:
            return 3
        case TableSections.Spacer3.rawValue:
            return 1
        case TableSections.BehavioralCharacteristics.rawValue:
            if animal?.environment.children != nil {
                return 4
            }
            return 3
        case TableSections.Spacer4.rawValue:
            return 1
        case TableSections.Contact.rawValue:
            if animal?.contact.email != nil || animal?.contact.phone != nil {
                return 3
            }
            return 0
        case TableSections.Spacer5.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == TableSections.Photo.rawValue {
            return tableView.frame.width
        }else if indexPath.section == TableSections.Contact.rawValue {
            if indexPath.row == 1, animal?.contact.email == nil  {
                return 0
            }else if indexPath.row == 2, animal?.contact.phone == nil {
                return 0
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == TableSections.Photo.rawValue {
            return tableView.frame.width
        }else if indexPath.section == TableSections.Contact.rawValue {
            if indexPath.row == 1, animal?.contact.email == nil  {
               return 0
            }else if indexPath.row == 2, animal?.contact.phone == nil {
               return 0
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    @IBAction func emailButtonTapped(_ sender: UIButton) {
        if let email = animal?.contact.email, let emailUrl = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(emailUrl) {
            UIApplication.shared.open(emailUrl, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func phoneButtonTapped(_ sender: UIButton) {
        if let phone = animal?.contact.phone, let phoneUrl = URL(string: "tel:\(phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())"), UIApplication.shared.canOpenURL(phoneUrl) {
            UIApplication.shared.open(phoneUrl, options: [:], completionHandler: nil)
        }
    }
}
