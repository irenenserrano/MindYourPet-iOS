//
//  ContentView.swift
//  MindYourPet
//
//  Created by Irene Serrano on 8/20/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct ContentView: View {
    @State private var showAddPetView = false
    @State private var listOfDictionaries: [[String: Any]] = []
    @State private var emptyList: Bool = false
    
    struct MyDataItem: Identifiable {
        let id = UUID()
        let profileID: String
        let name: String
        let age: Int
        let profileImageURL: String
        let speciesEmoji: String
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationLink(destination: CreatePetProfile(species: .dog), isActive: $showAddPetView) {
                    EmptyView()
                }// end NavigationLink
                
                let newListOfDicts = listOfDictionaries.map { dict in
                    MyDataItem(profileID: dict["id"] as! String, name: dict["name"] as! String, age: dict["age"] as! Int, profileImageURL: dict["profileImageURL"] as! String, speciesEmoji: dict["speciesEmoji"] as! String)
                }
                List {
                    if emptyList {
                        Text("Add a pet to your list!")
                    }
                    ForEach(newListOfDicts) { dict in
                        VStack{
                            NavigationLink {
                                ProfileDetailView(petProfileID: dict.profileID)
                            } label: {
                                HStack{
                                    let imageURL = URL(string: dict.profileImageURL) ?? URL(string: "")
                                    
                                    AsyncImage(url: imageURL) { image in
                                        image
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    } placeholder: {
                                        Image(.defaultProfilePic)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    }
                                    Text("\(dict.name)")
                                }// end HStack
                            }// end NavigationLink
                        }// end VStack
                    }// end ForEach
                    .listRowBackground(Color.pink.ignoresSafeArea().brightness(0.7))
                }// end List
                .scrollContentBackground(.hidden)
                .background(Color.pink.ignoresSafeArea().brightness(0.5))
            }// end ZStack
            .onAppear {
                Task {
                    listOfDictionaries = await loadData()
                    
                    if listOfDictionaries.isEmpty {
                        emptyList.toggle()
                    }
                }
            }// end onAppear
            .navigationTitle("Your Pets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(red: 0.9529, green: 0.6901, blue: 0.8274 ), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddPetView.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .foregroundColor(.pink)
                            .brightness(0.7)
                    }
                }// end ToolbarItem
            }// end .toolbar
        }// end ZStack
    }// end NavigationStack
}// end body

func loadData() async -> [[String: Any]] {
    let db = Firestore.firestore()
    var pets: [[String: Any]] = []
    do {
        let querySnapshot = try await db.collection("Pets").getDocuments()
        for document in querySnapshot.documents {
            let documentData = document.data()
            let documentID = document.documentID
            let petData: [String: Any] = [
                "id": documentID,
                "name": documentData["name"] as! String,
                "profileImageURL": documentData["profileImageURL"] as! String,
                "age": documentData["age"] as! Int,
                "speciesEmoji": documentData["speciesEmoji"] as! String]
            pets.append(petData)
        }
    } catch {
        print("Cannot fetch data from Firestore: \(error)")
    }
    
    return pets
}

#Preview {
    ContentView()
}





