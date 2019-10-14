//
//  AnimalTableViewCell.swift
//  PawFinder
//
//  Created by Greg Silesky on 10/12/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import UIKit
import Siesta

class AnimalTableViewCell: UITableViewCell {
    
    static let kAnimalTableViewCell = "kAnimalTableViewCell"
    
    @IBOutlet weak var remoteImageView: RemoteImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageAndBreedLabel: UILabel!
    
    var animal: Animal? {
        didSet{
            if let animal = animal {
                if let photo = animal.photos.first {
                    remoteImageView.imageURL = photo.medium
                }else{
                    remoteImageView.imageURL = nil
                    remoteImageView.image = UIImage(named: "ComingSoon")
                }
                nameLabel.text = animal.name.capitalized
                if let primaryBreed = animal.breeds.primary {
                    ageAndBreedLabel.text = "\(animal.age) - \(primaryBreed)"
                }else{
                    ageAndBreedLabel.text = "\(animal.age)"
                }
                
            }
        }
    }
}
