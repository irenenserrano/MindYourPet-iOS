//
//  Pet.swift
//  MindYourPet
//
//  Created by Irene Serrano on 8/20/25.
//
import Foundation
import FirebaseFirestore
import Firebase

struct Pet: Identifiable, Codable {
    @DocumentID var documentID: String?
    let name: String
    let speciesEmoji: SpeciesModel.ID
    var profileImageURL = "" // ? makes it so that this property is considered optional
    var age: Int
    
    var id: String {self.name}
    
    var dictionary: [String: Any] {
        return ["name": name,
                "speciesEmoji": speciesEmoji,
                "profileImageURL": profileImageURL,
                "age": age]
    }
}
