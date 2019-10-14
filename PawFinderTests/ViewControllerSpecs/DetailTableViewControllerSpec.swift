//
//  DetailTableViewControllerSpec.swift
//  PawFinderTests
//
//  Created by Greg Silesky on 10/13/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import Quick
import Nimble
@testable import Paw_Finder

class DetailTableViewControllerSpec: QuickSpec {
    override func spec() {
        var viewController: DetailTableViewController!
        
        describe("DetailTableViewControllerSpec"){
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                viewController = storyboard.instantiateViewController(withIdentifier: "DetailTableViewController") as? DetailTableViewController
            }
            context("when view loads"){
                it("should set title and label to animals name"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogChina", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.title).toEventually(equal("China"))
                    expect(viewController.nameLabel.text).toEventually(equal("China"))
                }
                
                it("should set age and breed of the animal"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogChina", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.ageAndBreedLabel.text).toEventually(equal("Baby - Terrier"))
                }
                
                it("should set physical characteristics"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogChina", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.tableView.numberOfRows(inSection: 4)).toEventually(equal(4))
                    expect(viewController.sizeLabel.text).toEventually(equal("Size - Medium"))
                    expect(viewController.genderLabel.text).toEventually(equal("Gender - Female"))
                    expect(viewController.ageLabel.text).toEventually(equal("Age - Baby"))
                    expect(viewController.coatLabel.text).toEventually(beNil())
                }
                
                it("should set health information"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogChina", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.tableView.numberOfRows(inSection: 6)).toEventually(equal(3))
                    expect(viewController.spayedNeuteredLabel.text).toEventually(equal("Spayed/Neutered - Yes"))
                    expect(viewController.shotsUpToDateLabel.text).toEventually(equal("Shots Up to Date - Yes"))
                }
                
                it("should set behavioral characteristics"){
                    //Arrange
                     let url = Bundle(for: type(of: self)).url(forResource: "DogChina", withExtension: "json")!
                     let data = try! Data(contentsOf: url)
                     let jsonDecoder = JSONDecoder()
                     viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                     //Act
                     let _ = viewController.view
                     //Assert
                     expect(viewController.tableView.numberOfRows(inSection: 8)).toEventually(equal(4))
                     expect(viewController.houseTrainedLabel.text).toEventually(equal("House Trained - No"))
                     expect(viewController.specialNeedsLabel.text).toEventually(equal("Special Needs - No"))
                     expect(viewController.goodWithKidsLabel.text).toEventually(equal("Good with Kids - Yes"))
                }
            }
            
            context("when photo of animal is available"){
                it("should begin loading image"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogChina", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.remoteImageView.imageURL).toEventuallyNot(beNil())
                    expect(viewController.tableView.numberOfRows(inSection: 0)).toEventually(equal(1))
                }
            }
            
            context("when no photo is avaiable"){
                it("should hide image"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogKota", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.remoteImageView.imageURL).toEventually(beNil())
                    expect(viewController.tableView.numberOfRows(inSection: 0)).toEventually(equal(0))
                }
            }
            
            context("when breed is unkonwn"){
                it("should hide the breed section"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogUnknownBreed", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.tableView.numberOfRows(inSection: 2)).toEventually(equal(0))
                    expect(viewController.primaryBreedLabel.text).toEventually(beNil())
                    expect(viewController.secondaryBreedLabel.text).toEventually(beNil())
                }
            }
            
            context("when breed is mixed"){
                it("should display primary and secondary breeds"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogKota", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.tableView.numberOfRows(inSection: 2)).toEventually(equal(3))
                    expect(viewController.primaryBreedLabel.text).toEventually(equal("Primary - Husky"))
                    expect(viewController.secondaryBreedLabel.text).toEventually(equal("Secondary - Great Pyrenees"))
                }
            }
            
            context("when purebred breed"){
                it("should display primary breed"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogChina", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.tableView.numberOfRows(inSection: 2)).toEventually(equal(2))
                    expect(viewController.primaryBreedLabel.text).toEventually(equal("Primary - Terrier"))
                    expect(viewController.secondaryBreedLabel.text).toEventually(beNil())
                }
            }
            
            context("when coat is available"){
                it("should display coat in physical characteristics"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogKota", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.tableView.numberOfRows(inSection: 4)).toEventually(equal(5))
                    expect(viewController.coatLabel.text).toEventually(equal("Coat - Long"))
                }
            }
            
            context("when good with kids is unavailable"){
                it("should hide good with kids attribute"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogUnknownBreed", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.tableView.numberOfRows(inSection: 8)).toEventually(equal(3))
                    expect(viewController.goodWithKidsLabel.text).toEventually(beNil())
                }
            }
            
            context("when email is available but no phone number"){
                it("should show email"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogKota", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.tableView.numberOfRows(inSection: 10)).toEventually(equal(3))
                    expect(viewController.tableView(viewController.tableView, heightForRowAt: IndexPath(row: 2, section: 10))).toEventually(equal(0))
                    expect(viewController.emailButton.titleLabel?.text).toEventually(equal("foster.mattysheartandsoul@gmail.com"))
                }
            }
            
            context("when phone is available but no email"){
                it("should show phone"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogChina", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.tableView.numberOfRows(inSection: 10)).toEventually(equal(3))
                    expect(viewController.tableView(viewController.tableView, heightForRowAt: IndexPath(row: 1, section: 10))).toEventually(equal(0))
                    expect(viewController.phoneButton.titleLabel?.text).toEventually(equal("(651) 645-7387"))
                }
            }
            
            context("when email and phone is available"){
                it("should show email and phone"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogUnknownBreed", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.tableView.numberOfRows(inSection: 10)).toEventually(equal(3))
                    expect(viewController.emailButton.titleLabel?.text).toEventually(equal("info@animalhumanesociety.org"))
                    expect(viewController.phoneButton.titleLabel?.text).toEventually(equal("(651) 645-7387"))
                }
            }
            
            context("when email and phone are not available"){
                it("should hide contact section"){
                    //Arrange
                    let url = Bundle(for: type(of: self)).url(forResource: "DogMartina", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    let jsonDecoder = JSONDecoder()
                    viewController.animal = try! jsonDecoder.decode(Animal.self, from: data)
                    //Act
                    let _ = viewController.view
                    //Assert
                    expect(viewController.tableView.numberOfRows(inSection: 10)).toEventually(equal(0))
                }
            }
        }
    }
}

