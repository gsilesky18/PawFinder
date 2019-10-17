//
//  DecoderHelper.swift
//  PawFinderTests
//
//  Created by Greg Silesky on 10/17/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import Foundation
@testable import Paw_Finder

class DecoderHelper {

    static let sharedInstance = DecoderHelper()
    
    private init(){}
    
    func GetAnimals(from file: String) -> GetAnimalsResponse {
        let url = Bundle(for: type(of: self)).url(forResource: file, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let jsonDecoder = JSONDecoder()
        return try! jsonDecoder.decode(GetAnimalsResponse.self, from: data)
    }
    
    func GetAnimal(from file: String) -> Animal {
        let url = Bundle(for: type(of: self)).url(forResource: file, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let jsonDecoder = JSONDecoder()
        return try! jsonDecoder.decode(Animal.self, from: data)
    }
}
