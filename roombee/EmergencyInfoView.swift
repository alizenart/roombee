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

            if emergencyInfoViewModel.emergencyContacts.isEmpty {
                Text("No emergency contacts yet. Add one using the button above.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                List {
                    ForEach(emergencyInfoViewModel.emergencyContacts) { contact in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(contact.name)
                                    .font(.headline)
                                Button(action: {
                                    makePhoneCall(to: contact.phoneNumber)
                                }) {
                                    Text("Phone: \(contact.phoneNumber)")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                Text("Relationship: \(contact.relationship)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            let contact = emergencyInfoViewModel.emergencyContacts[index]
                            emergencyInfoViewModel.deleteContact(contactID: contact.id, userID: contact.user_id)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            emergencyInfoViewModel.fetchContacts(userID: authViewModel.user_id ?? "80003")
        }
    }

    private func makePhoneCall(to number: String) {
        let phoneNumber = "tel://\(number)"
        if let url = URL(string: phoneNumber), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
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
