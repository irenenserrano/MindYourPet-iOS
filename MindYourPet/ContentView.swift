//
//  ContentView.swift
//  MindYourPet
//
//  Created by Irene Serrano on 8/20/25.
//

import SwiftUI
import FirebaseCore

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: CreatePetProfile(species: .dog)) {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, world!")
                }
               
            }
            .padding()
        }// end NavigationStack
       
    }// end body
}// end struct

#Preview {
    ContentView()
}



