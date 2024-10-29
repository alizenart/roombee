//
//  EmergencyInfoView.swift
//  roombee
//
//  Created by Alison Bai on 10/29/24.
//

import SwiftUI

struct EmergencyInfoView: View {
    @StateObject private var emergencyInfoViewModel = EmergencyInfoViewModel()
    @State private var showNewContactForm = false

    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { showNewContactForm = true }) {
                    Text("Add Contact")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showNewContactForm) {
                    NewEmergencyContactForm(showForm: $showNewContactForm, viewModel: emergencyInfoViewModel, userID: authViewModel.user_id ?? "80003")
                }
            }
            .padding()

            Text("Emergency Contacts")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .foregroundColor(.red)

            List {
                Section(header: Text("Your Contacts").font(.headline)) {
                    if emergencyInfoViewModel.userContacts.isEmpty {
                        Text("No emergency contacts yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(emergencyInfoViewModel.userContacts) { contact in
                            ContactRow(contact: contact)
                        }
                        .onDelete { indexSet in
                            deleteContact(from: indexSet, in: &emergencyInfoViewModel.userContacts)
                        }
                    }
                }

                Section(header: Text("Roommate's Contacts").font(.headline)) {
                    if emergencyInfoViewModel.roommateContacts.isEmpty {
                        Text("No contacts found for your roommate.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(emergencyInfoViewModel.roommateContacts) { contact in
                            ContactRow(contact: contact)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            emergencyInfoViewModel.fetchContacts(
                userID: authViewModel.user_id ?? "80003",
                roommateID: "roommateID" // Replace with actual roommate ID logic
            )
        }
    }

    private func deleteContact(from indexSet: IndexSet, in contacts: inout [EmergencyContactInfo]) {
        if let index = indexSet.first {
            let contact = contacts[index]
            emergencyInfoViewModel.deleteContact(contactID: contact.id, userID: contact.user_id)
        }
    }
}

struct ContactRow: View {
    let contact: EmergencyContactInfo

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(contact.name).font(.headline)
                Text("Phone: \(contact.phoneNumber)").font(.subheadline)
                Text("Relationship: \(contact.relationship)").font(.footnote).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }
}


struct EmergencyContact: Identifiable {
    let id = UUID()
    var name: String
    var phoneNumber: String
    var relationship: String
}

struct NewEmergencyContactForm: View {
    @Binding var showForm: Bool
    var viewModel: EmergencyInfoViewModel  // Inject ViewModel
    let userID: String

    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var relationship = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                TextField("Relationship", text: $relationship)
            }
            .navigationBarTitle("New Contact", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                showForm = false
            }, trailing: Button("Save") {
                let newContact = EmergencyContactInfo(
                    user_id: userID,  // Replace with actual user ID
                    name: name,
                    phoneNumber: phoneNumber,
                    relationship: relationship
                )
                viewModel.addContact(contact: newContact)
                showForm = false
            })
        }
    }
}


#Preview {
    EmergencyInfoView()
}
