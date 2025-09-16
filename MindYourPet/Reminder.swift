//
//  Pet.swift
//  MindYourPet
//
//  Created by Irene Serrano on 8/20/25.
//
import Foundation
import FirebaseFirestore
import Firebase

struct Reminder: Identifiable, Codable {
    @DocumentID var documentID: String?
    let title: String
    let reminderTime: Date
    let notes: String
    let repeating: Bool
    
    var id: String {self.title}
    
    var dictionary: [String: Any] {
        return [
            "title": title,
            "reminderTime": reminderTime,
            "notes": notes,
            "repeating": repeating
        ]
    }
}
