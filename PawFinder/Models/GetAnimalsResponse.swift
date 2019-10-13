//
//  GetAnimalsResponse.swift
//  PawFinder
//
//  Created by Greg Silesky on 10/11/19.
//  Copyright © 2019 Greg Silesky. All rights reserved.
//

import Foundation

struct GetAnimalsResponse: Decodable {
    let animals: [Animal]
    let pagination: Pagination
}

struct Animal: Decodable {
    let id: Int
    let organization_id: String
    let url: String
    let type: String
    let species: String
    let breeds: Breeds
    let colors : Colors
    let age: String
    let gender: String
    let size: String
    let coat: String?
    let attributes: Attributes
    let environment: Environment
    let tags: [String]
    let name: String
    let description: String?
    let photos: [Photo]
    let status: String
    let published_at: String //TODO: Change to date
    let contact: Contact
}

struct Breeds: Decodable {
    let primary: String?
    let secondary: String?
    let mixed: Bool
    let unknown: Bool
}
struct Colors: Decodable {
    let primary: String?
    let secondary: String?
    let tertiary: String?
}
struct Attributes: Decodable {
    let spayed_neutered: Bool
    let house_trained: Bool
    let declawed: Bool?
    let special_needs: Bool
    let shots_current: Bool
}
struct Environment: Decodable {
    let children: Bool?
    let dogs: Bool?
    let cats: Bool?
}
struct Photo: Decodable {
    let small: String
    let medium: String
    let large: String
    let full: String
}
struct Contact: Decodable {
    let email: String?
    let phone: String?
    let address: Address
}
struct Address: Decodable {
    let address1: String?
    let address2: String?
    let city: String
    let state: String
    let postcode: String
    let country: String
}
struct Pagination: Decodable {
    let count_per_page: Int
    let total_count: Int
    let current_page: Int
    let total_pages: Int
}
