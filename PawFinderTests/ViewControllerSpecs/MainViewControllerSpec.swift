//
//  MainViewControllerSpec.swift
//  PawFinderTests
//
//  Created by Greg Silesky on 10/12/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import Quick
import Nimble
@testable import Paw_Finder

class MainViewControllerSpec: QuickSpec {
    override func spec() {
        var viewController: MainViewController!
        
        describe("MainViewControllerSpec"){
            describe("on load"){
                beforeEach {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let navigationController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController
                    UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController = navigationController
                    viewController = navigationController.topViewController as? MainViewController
                    let _ = navigationController.view
                    let _ = viewController.view
                    viewController.aminalResource?.wipe()
                }
                
                context("when no animals are available"){
                    it("should have empty table view"){
                        //Act
                        viewController.animals = []
                        //Asset
                        expect(viewController.tableView.numberOfRows(inSection: 0)).toEventually(equal(0))
                    }
                }
                
                context("when 10 animals are available"){
                    it("should have 10 rows in the table view"){
                        //Arrange
                        let url = Bundle(for: type(of: self)).url(forResource: "Dogs10", withExtension: "json")!
                        let data = try! Data(contentsOf: url)
                        let jsonDecoder = JSONDecoder()
                        let response = try! jsonDecoder.decode(GetAnimalsResponse.self, from: data)
                        //Act
                        viewController.animals = response.animals
                        //Asset
                        expect(viewController.tableView.numberOfRows(inSection: 0)).toEventually(equal(10))
                    }
                }
                context("when animal is set in cell"){
                    it("should load image and display info"){
                        //Arrange
                        let url = Bundle(for: type(of: self)).url(forResource: "Dogs10", withExtension: "json")!
                        let data = try! Data(contentsOf: url)
                        let jsonDecoder = JSONDecoder()
                        let response = try! jsonDecoder.decode(GetAnimalsResponse.self, from: data)
                        //Act
                        viewController.animals = response.animals
                        //Assert
                        let cell = viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AnimalTableViewCell
                        expect(cell.remoteImageView.imageURL).toEventuallyNot(beNil())
                        expect(cell.nameLabel.text).toEventually(equal("China"))
                        expect(cell.ageAndBreedLabel.text).toEventually(equal("Baby - Terrier"))
                    }
                }
                
                context("when animal doesn't have a photo"){
                    it("should display coming soon"){
                        //Arrange
                        let url = Bundle(for: type(of: self)).url(forResource: "Dogs10", withExtension: "json")!
                        let data = try! Data(contentsOf: url)
                        let jsonDecoder = JSONDecoder()
                        let response = try! jsonDecoder.decode(GetAnimalsResponse.self, from: data)
                        //Act
                        viewController.animals = response.animals
                        //Assert
                        let cell = viewController.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! AnimalTableViewCell
                        expect(cell.remoteImageView.imageURL).toEventually(beNil())
                        expect(cell.remoteImageView.image).toEventually(equal(UIImage(named: "ComingSoon")))
                    }
                }
            }
        }
    }
}
