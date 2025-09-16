//
//  Alarm.swift
//  MindYourPet
//
//  Created by Irene Serrano on 9/16/25.
//

import Foundation
import FirebaseFirestore
import Firebase

struct Alarm {
    @DocumentID var documentID: String?
    let label: String
    let alarmTime: Date
    let isActive: Bool
    
    var id: String {self.label}
    
    var dictionary: [String: Any] {
        return [
            "label": label,
            "alarmTime": alarmTime,
            "isActive": isActive
        ]
    }
}
