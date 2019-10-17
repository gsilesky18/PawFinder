//
//  MainViewControllerSpec.swift
//  PawFinderTests
//
//  Created by Greg Silesky on 10/12/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import Quick
import Nimble
import Siesta
@testable import Paw_Finder

class MainViewControllerSpec: QuickSpec {
    
    override func spec() {
        
        var viewController: MainViewController!
        
        describe("MainViewControllerSpec"){
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let navigationController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController
                UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController = navigationController
                viewController = navigationController.topViewController as? MainViewController
                let _ = navigationController.view
                let _ = viewController.view
                viewController.aminalResource?.wipe()
            }
            
            context("when response is received from the api"){
                it("should hide the loading indicator"){
                    //Act
                    viewController.resourceChanged(viewController.aminalResource!, event: .newData(.network))
                    //Assert
                    expect(viewController.activityIndicator.isHidden).toEventually(beTrue())
                    expect(viewController.activityIndicator.isAnimating).toEventually(beFalse())
                    expect(viewController.tableView.isHidden).toEventually(beFalse())
                }
            }

            context("when second page of animals is loading"){
                it("should not display loading indicator"){
                    //Arrange
                    viewController.currentPage = 2
                    //Act
                    viewController.resourceChanged(viewController.aminalResource!, event: .requested)
                    //Assert
                    expect(viewController.activityIndicator.isHidden).toEventually(beTrue())
                    expect(viewController.activityIndicator.isAnimating).toEventually(beFalse())
                    expect(viewController.tableView.isHidden).toEventually(beFalse())
                }
            }

            context("when networking error occurs"){
                it("should display alert message"){
                    //Act
                    viewController.resourceChanged(viewController.aminalResource!, event: .error)
                    //Assert
                    expect(viewController.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                }
            }

            context("when cell loads with animal"){
                it("should load image and display info"){
                    //Arrange
                    let response = DecoderHelper.sharedInstance.GetAnimals(from: "Dogs10")
                    //Act
                    viewController.totalPages = response.pagination.total_pages
                    viewController.totalAnimal = response.pagination.total_count
                    viewController.animals.append(contentsOf: response.animals)
                    viewController.tableView.reloadData()
                    //Assert
                    let cell = viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AnimalTableViewCell
                    expect(cell.remoteImageView.imageURL).toEventuallyNot(beNil())
                    expect(cell.nameLabel.text).toEventually(equal("China"))
                    expect(cell.ageAndBreedLabel.text).toEventually(equal("Baby - Terrier"))
                }
            }

            context("when cell loads with animal and image is unavailable"){
                it("should display coming soon"){
                    //Arrange
                    let response = DecoderHelper.sharedInstance.GetAnimals(from: "Dogs10")
                    //Act
                    viewController.totalPages = response.pagination.total_pages
                    viewController.totalAnimal = response.pagination.total_count
                    viewController.animals.append(contentsOf: response.animals)
                    viewController.tableView.reloadData()
                    //Assert
                    let cell = viewController.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! AnimalTableViewCell
                    expect(cell.remoteImageView.imageURL).toEventually(beNil())
                    expect(cell.remoteImageView.image).toEventually(equal(UIImage(named: "ComingSoon")))
                }
            }

            context("when cell is loading"){
                it("should display activity indicator"){
                    //Arrange
                    let response = DecoderHelper.sharedInstance.GetAnimals(from: "Dogs10")
                    viewController.totalPages = response.pagination.total_pages
                    viewController.totalAnimal = response.pagination.total_count
                    viewController.animals.append(contentsOf: response.animals)
                    viewController.tableView.reloadData()
                    //Act
                    viewController.tableView.scrollToRow(at: IndexPath(row: 30, section: 0), at: .middle, animated: false)
                    viewController.aminalResource?.wipe()
                    //Assert
                    let cell = viewController.tableView.cellForRow(at: IndexPath(row: 30, section: 0)) as! AnimalTableViewCell
                    expect(cell.activityIndicator.isHidden).toEventually(beFalse())
                    expect(cell.remoteImageView.isHidden).toEventually(beTrue())
                    expect(cell.nameLabel.isHidden).toEventually(beTrue())
                    expect(cell.ageAndBreedLabel.isHidden).toEventually(beTrue())
                }
            }
        }
    }
}
