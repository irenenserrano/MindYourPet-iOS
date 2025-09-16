//
//  ProfileDetailView.swift
//  MindYourPet
//
//  Created by Irene Serrano on 9/15/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct ProfileDetailView: View {
    @State var note: String = "Add care notes..."
    @State private var listOfReminders: [[String: Any]] = []
    @State private var listOfAlarms: [[String: Any]] = []
    @State private var emptyRemindersList: Bool = false
    @State private var emptyAlarmsList: Bool = false
    @State var petProfileID: String
    @FocusState private var isEditorFocused: Bool
    @State var timeString: String = ""
    struct MyReminderItem: Identifiable {
        let id = UUID()
        let title: String
        let reminderTime: Date
        let notes: String
        let repeating: Bool
    }
    
    struct MyAlarmItem: Identifiable {
        let id = UUID()
        let label: String
        let alarmTime: Date
        let isActive: Bool
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                let newListOfReminders = listOfReminders.map { reminder in
                    MyReminderItem(
                        title: reminder["title"] as! String,
                        reminderTime: reminder["reminderTime"] as! Date,
                        notes: reminder["notes"] as! String,
                        repeating: reminder["repeating"] as! Bool
                    )
                }// end newListOfReminders
                
                let newListOfAlarms = listOfAlarms.map { alarm in
                    MyAlarmItem(
                        label: alarm["label"] as! String,
                        alarmTime: alarm["alarmTime"] as! Date,
                        isActive: alarm["isActive"] as! Bool
                    )
                }// end newListOfReminders
                
                List {
                    Section {
                        TextEditor(text: $note)
                            .frame(height: 100)
                            .focused($isEditorFocused)
                            .onAppear {
                                Task {
                                    await fetchCareNotes(profileID: petProfileID)
                                }
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        isEditorFocused = false
                                    }
                                }
                            }
                    } header: {
                        Text("Care notes")
                            .font(.title.bold())
                            .foregroundStyle(.black)
                    }// end Section
                    .listRowBackground(Color.pink.brightness(0.7))
                    .onChange(of: note) { newValue in
                        Task {
                            await uploadCareNotes(text: newValue, profileID: petProfileID)
                        }
                    }
                    
                    Section {
                        if emptyRemindersList {
                            Text("Add a reminder...")
                        }
                        ForEach(newListOfReminders) { reminder in
                            VStack{
                                NavigationLink {
                                    
                                } label: {
                                    HStack {
                                        Text(reminder.title)
                                    }// end HStack
                                }
                            }
                        }// end ForEach
                    } header: {
                        HStack {
                            Text("Reminders")
                                .font(.title.bold())
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .foregroundColor(.pink)
                                    .brightness(0.7)
                            }// end Button
                        }// end HStack
                    }// end Section
                    .listRowBackground(Color.pink.brightness(0.7))
                    
                    Section {
                        if emptyAlarmsList {
                            Text("Add an alarm...")
                        }
                        ForEach(newListOfAlarms) { alarm in
                            VStack{
                                NavigationLink {
                                    
                                } label: {
                                    HStack {
                                        Text(alarm.label)
                                        Text(timeString)
                                        Spacer()
                                        
                                        if alarm.isActive {
                                            Text("ON")
                                        } else {
                                            Text("OFF")
                                        }
                                    }// end HStack
                                    .onAppear {
                                        Task {
                                            let dateformatter = DateFormatter()
                                            dateformatter.dateFormat = "h:mm a"
                                            timeString = dateformatter.string(from: alarm.alarmTime)
                                        }
                                    }
                                }// end NavigationLink
                            }// end VStack
                        }// end ForEach
                    } header: {
                        HStack {
                            Text("Alarms")
                                .font(.title.bold())
                                .foregroundStyle(.black)
                            Spacer()
                            Button {
                                
                            } label: {
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .foregroundColor(.pink)
                                    .brightness(0.7)
                            }// end Button
                        }// end HStack
                    }// end Section
                    .listRowBackground(Color.pink.brightness(0.7))
                }// end List
                .scrollContentBackground(.hidden)
                .background(Color.pink.ignoresSafeArea().brightness(0.5))
            }// end ZStack
            .onAppear {
                Task {
                    listOfReminders = await loadReminders(profileID: petProfileID)
                    
                    if listOfReminders.isEmpty {
                        emptyRemindersList.toggle()
                    }
                    
                    listOfAlarms = await loadAlarms(profileID: petProfileID)
                    
                    if listOfAlarms.isEmpty {
                        emptyAlarmsList.toggle()
                    }
                }// end Task
                
            }// end onAppear
        }// end NavigationStack
    }// end body
    
    func loadReminders(profileID: String) async -> [[String: Any]]{
        let db = Firestore.firestore()
        var reminders: [[String: Any]] = []
        
        do {
            let querySnapshot = try await db.collection("Pets").document(profileID).collection("Reminders").getDocuments()
            for document in querySnapshot.documents {
                let documentData = document.data()
                let timestamp = documentData["reminderTime"] as? Timestamp
                let date = timestamp?.dateValue()
                
                let reminder: [String: Any] = [
                    "title": documentData["title"] as! String,
                    "reminderTime": date!,
                    "notes": documentData["notes"] as! String,
                    "repeating": documentData["repeating"] as! Bool
                ]
                
                reminders.append(reminder)
            }
        } catch {
            print("Cannot fetch data from firestore")
        }
        return reminders
    }// end loadData
    
    func loadAlarms(profileID: String) async -> [[String: Any]]{
        let db = Firestore.firestore()
        var alarms: [[String: Any]] = []
        
        do {
            let querySnapshot = try await db.collection("Pets").document(profileID).collection("Alarms").getDocuments()
            for document in querySnapshot.documents {
                let documentData = document.data()
                let timestamp = documentData["alarmTime"] as? Timestamp
                let time = timestamp?.dateValue()
                
                let alarm: [String: Any] = [
                    "label": documentData["label"] as! String,
                    "alarmTime": time!,
                    "isActive": documentData["isActive"] as! Bool
                ]
                
                alarms.append(alarm)
            }
        } catch {
            print("Cannot fetch data from firestore")
        }
        return alarms
    }// end loadData
    
    func uploadCareNotes(text: String, profileID: String) async -> Bool{
        let db = Firestore.firestore()
        
        do {
            try await db.collection("Pets").document(profileID).updateData(["careNotes": text])
            return true
        } catch {
            print("Could not upload care notes: \(error)")
            return false
        }
    }// end uploadCareNotes

    func fetchCareNotes(profileID: String) async {
        let db = Firestore.firestore()
        
        let documentRef = try await db.collection("Pets").document(profileID)
        
        documentRef.getDocument { documentSnapShot, error in
            if let error = error {
                print("Error getting document: \(error)")
            }
            
            guard let document = documentSnapShot, document.exists else {
                print("Document does not exist")
                return
            }
            
            if let data = document.data() {
                if data["careNotes"] != nil {
                    self.note = data["careNotes"] as! String
                }
               
            }
        }
    }// end fetchCareNotes
    
}// end struct

#Preview {
    @Previewable @State var profileID = "7E0F2E3F-5E34-4534-9B43-E57D06AEA107"
    ProfileDetailView(petProfileID: profileID)
}
