//
//  SpeciesModel.swift
//  MindYourPet
//
//  Created by Irene Serrano on 8/20/25.
//

enum SpeciesModel: String, CaseIterable, Identifiable {
    case dog = "🐕"
    case cat = "🐈"
    case bird = "🦜"
    case reptile = "🐍"
    case rodent = "🐭"
    case equine = "🐎"
    
    var id: String { self.rawValue }
}
