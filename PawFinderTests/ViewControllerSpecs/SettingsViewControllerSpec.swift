//
//  SettingsViewControllerSpec.swift
//  PawFinderTests
//
//  Created by Greg Silesky on 10/15/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import Quick
import Nimble
@testable import Paw_Finder

class SettingsViewControllerSpec: QuickSpec {
    
    override func spec() {
        
        var viewController: SettingsViewController!
        
        describe("SettingsViewControllerSpec"){
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                viewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
                UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController = viewController
                let _ = viewController.view
            }
            
            context("when animal type changed to dog"){
                it("should change the user defualts"){
                    //Arrange
                    let mockUserDefaults =  MockUserDefaults()
                    viewController.userDefaults = mockUserDefaults
                    viewController.typeSegmentedControl.selectedSegmentIndex = 0
                    //Act
                    viewController.typeSegmentedControlChanged(viewController.typeSegmentedControl)
                    //Asset
                    expect(mockUserDefaults.typeChanged).toEventually(beTrue())
                    expect(viewController.isDirty).toEventually(beTrue())
                }
            }
            
            context("when animal type changed to cat"){
                it("should change the user defualts"){
                    //Arrange
                    let mockUserDefaults = MockUserDefaults()
                    viewController.userDefaults = mockUserDefaults
                    viewController.typeSegmentedControl.selectedSegmentIndex = 1
                    //Act
                    viewController.typeSegmentedControlChanged(viewController.typeSegmentedControl)
                    //Asset
                    expect(mockUserDefaults.typeChanged).toEventually(beTrue())
                    expect(viewController.isDirty).toEventually(beTrue())
                }
            }
            
            context("when nothing is entered in the zip code field"){
                it("should display alert message"){
                    //Arrange
                    viewController.zipCodeTextField.text = nil
                    //Act
                    viewController.searchButton.sendActions(for: .touchUpInside)
                    //Assert
                    expect(viewController.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                }
            }
            
            context("when zip code is less than 5 digits"){
                it("should not be a valid zip code"){
                    //Arrange
                    viewController.zipCodeTextField.text = "5552"
                    //Act
                    viewController.searchButton.sendActions(for: .touchUpInside)
                    //Assert
                    expect(viewController.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                }
            }
            
            context("when zip code is more than 5 digits"){
                it("should not be a valid zip code"){
                    //Arrange
                    viewController.zipCodeTextField.text = "555234"
                    //Act
                    viewController.searchButton.sendActions(for: .touchUpInside)
                    //Assert
                    expect(viewController.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                }
            }
            
            context("when zip code is 5 digits"){
                it("should be a valid zip code"){
                    //Arrange
                    let mockUserDefaults = MockUserDefaults()
                    viewController.userDefaults = mockUserDefaults
                    viewController.zipCodeTextField.text = "55555"
                    //Act
                    viewController.searchButton.sendActions(for: .touchUpInside)
                    //Assert
                    expect(mockUserDefaults.zipCodeChanged).toEventually(beTrue())
                    expect(viewController.isDirty).toEventually(beTrue())
                }
            }
        }
    }
}
