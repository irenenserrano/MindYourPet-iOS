//
//  CreatePetProfile.swift
//  MindYourPet
//
//  Created by Irene Serrano on 8/20/25.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore
import UIKit
import FirebaseStorage

struct CreatePetProfile: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var profilePic: Image? = Image(.defaultProfilePic)
    @State var name = ""
    @State private var showAlert: Bool = false
    @State var species: SpeciesModel
    @State var age = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pink.ignoresSafeArea().brightness(0.5)
                
                VStack {
                    PhotosPicker(selection: $selectedItem) {
                        if let profilePic {
                            profilePic
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                        } else {
                            ZStack{
                                Rectangle()
                                    .fill(Color.pink)
                                    .brightness(0.7)
                                    .frame(width: 150, height: 150)
                                
                                Image(systemName: "pawprint")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.pink)
                                    .brightness(0.5)
                            }// end ZStack
                        }// end if else
                    }// end PhotosPicker
                    .onChange(of: selectedItem) {
                        Task {
                            if let loadedImage = try? await selectedItem?.loadTransferable(type: Image.self) {
                                profilePic = loadedImage
                            } else {
                                print("Failed to load image.")
                            }
                        }
                    }
                    
                    VStack(spacing: 10) {
                        TextField("What is your pet's name? ", text: $name)
                            .frame(height: 50)
                            .background(Color.pink.brightness(0.7))
                            .border(name.isEmpty && showAlert ? Color.gray : Color.pink, width: 1)
                            .padding(.horizontal, 10)
                        
                        TextField("How old is your pet? (optional)", text: $age)
                            .frame(height: 50)
                            .background(Color.pink.brightness(0.7))
                            .padding(.horizontal, 10)
                            .keyboardType(.decimalPad)
                        
                        Text("Select your pet's species")
                            .font(.title)
                            .bold(true)
                            .foregroundStyle(.pink).brightness(0.7)
                        
                        LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                            ForEach(SpeciesModel.allCases) { modelCase in
                                if species == modelCase {
                                    Button {
                                        species = modelCase
                                    } label: {
                                        Text(modelCase.rawValue)
                                            .font(.largeTitle)
                                            .overlay{
                                                RoundedRectangle(cornerRadius: 3)
                                                    .stroke(lineWidth: 3)
                                                    .fill(Color.pink)
                                                    .brightness(0.7)
                                                    .frame(width: 40, height: 40)
                                            }
                                    }
                                } else {
                                    Text(modelCase.rawValue)
                                        .font(.largeTitle)
                                        .onTapGesture {
                                            species = modelCase
                                        }
                                    
                                }// end if else
                            }// end ForEach
                        }// end LazyVGrid
                    }// end VStack
                }// end VStack
            }// end ZStack
            .navigationTitle("Create Pet Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(red: 0.9529, green: 0.6901, blue: 0.8274 ), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button ("Save") {
                        Task {
                            
                            if name.isEmpty {
                                showAlert.toggle()
                            }
                            var ageInYears: Int = -1
                            if age != "" && Int(age) != nil {
                                ageInYears = Int(age)!
                            }
                            
                            let newPet = Pet(name: name, speciesEmoji: species.id, profileImageURL: "", age: ageInYears)
                            
                            guard let profileImage = profilePic.asUIImage()  else {
                                print("Failed to converr Image to UIImage")
                                return
                            }
                            
                            if showAlert == false {
                                let success = await uploadDataToCloudStorage(pet: newPet, image: profileImage)
                                dismiss()
                            }
                            
                            
                        }
                    }// end Button
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Name required"), message: Text("Please enter a name for your pet"), dismissButton: .default(Text("OK")))
                    }
                }// end ToolBarItem
            }// end toolbar
        }// end NavigationStack
    }// end body
}

extension View {
    func asUIImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage
    }
}

func uploadDataToCloudStorage(pet: Pet, image: UIImage) async -> Bool {
    
    let petID = pet.id
    let imageName = UUID().uuidString // image file name
    let storage = Storage.storage() // Firebase Storage instance
    let storageRef = storage.reference().child("\(petID)/\(imageName).jpg")
    
    guard let resizedImage = image.jpegData(compressionQuality: 0.2) else {
        print("Error resizing image")
        return false
    }
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg" // allows you to see image in web browser
    
    var imageURLString = ""
    
    do {
        let _ = try await storageRef.putDataAsync(resizedImage, metadata: metadata)
        print("Image saved to cloud storage")
        do {
            let imageURL = try await storageRef.downloadURL()
            imageURLString = imageURL.absoluteString
        } catch {
            print("Error getting download URL: \(error)")
            return false
        }
    } catch {
        print ("Error saving image to cloud storage: \(error)")
        return false
    }
    
    let db = Firestore.firestore()
    
    do {
        var newPetProfile = pet
        newPetProfile.profileImageURL = imageURLString
        try await db.collection("Pets").document(imageName).setData(newPetProfile.dictionary)
        print("Pet Profile created successfully")
        return true
    } catch {
        print("Could not create new pet profile for \(pet.name): \(error)")
        return false
    }
}

#Preview {
    @Previewable @State var previewSpecies: SpeciesModel = .dog
    CreatePetProfile(species: previewSpecies)
}
