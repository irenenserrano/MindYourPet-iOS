//
//  Pet.swift
//  MindYourPet
//
//  Created by Irene Serrano on 8/20/25.
//
import UIKit

struct Pet: Identifiable {
    let name: String
    let speciesEmoji: Species
    var profileImage: UIImage?
    var age: Int? // ? makes it so that this property is considered optional
    
    var id: String {self.name}
     
    enum Species: String, CaseIterable {
        case dog = "🐶"
        case cat = "🐱"
        case bird = "🐦"
        case reptile = "🐍"
        case rodent = "🐭"
        case equine = "🐎"
    }
}
