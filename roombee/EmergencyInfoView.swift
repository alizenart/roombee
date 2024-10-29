//
//  EmergencyInfoView.swift
//  roombee
//
//  Created by Alison Bai on 10/29/24.
//

import SwiftUI

struct EmergencyInfoView: View {
    @StateObject private var emergencyInfoViewModel = EmergencyInfoViewModel()
    @State private var emergencyContacts: [EmergencyContact] = []
    @State private var showNewContactForm = false

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
                    NewEmergencyContactForm(showForm: $showNewContactForm, contacts: $emergencyContacts)
                }
            }
            .padding()

            Text("Emergency Contacts")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .foregroundColor(.red)

            if emergencyContacts.isEmpty {
                Text("No emergency contacts yet. Add one using the button above.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                List {
                    ForEach(emergencyContacts) { contact in
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
                        emergencyContacts.remove(atOffsets: indexSet)
                    }
                }
            }
        }
        .padding()
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
    @Binding var contacts: [EmergencyContact]

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
                let newContact = EmergencyContact(name: name, phoneNumber: phoneNumber, relationship: relationship)
                contacts.append(newContact)
                showForm = false
            })
        }
    }
}

#Preview {
    EmergencyInfoView()
}
