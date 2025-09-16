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
    @State private var initialText: String = "Add care notes..."
    @State private var listOfReminders: [[String: Any]] = []
    @State private var listOfAlarms: [[String: Any]] = []
    @State private var emptyRemindersList: Bool = false
    @State private var emptyAlarmsList: Bool = false
    @State var petProfileID: String
    
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
                    TextEditor(text: $initialText)
                        .frame(height: 100)
                        
                } header: {
                    Text("Care notes")
                        .font(.title.bold())
                        .foregroundStyle(.black)
                }// end Section
                .listRowBackground(Color.pink.brightness(0.7))
                
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
                        }
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
                                }// end HStack
                            }
                        }
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
                        }
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
}// end struct

#Preview {
    @Previewable @State var profileID = "7E0F2E3F-5E34-4534-9B43-E57D06AEA107"
    ProfileDetailView(petProfileID: profileID)
}
