//
//  MockUserDefaults.swift
//  PawFinderTests
//
//  Created by Greg Silesky on 10/16/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import Foundation
@testable import Paw_Finder

class MockUserDefaults: UserDefaults {
    
    var type: String?
    var zipCode: String?
    
    var typeChanged: Bool = false
    var zipCodeChanged: Bool = false
     
    override func string(forKey defaultName: String) -> String? {
        if defaultName == "type"{
            return type
        }else if defaultName == "zipCode"{
            return zipCode
        }
        return super.string(forKey: defaultName)
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        if defaultName == "type"{
            typeChanged = true
        }else if defaultName == "zipCode"{
            zipCodeChanged = true
        }
    }
    
}
