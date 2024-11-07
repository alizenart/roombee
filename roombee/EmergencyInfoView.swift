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
//            HStack {
//                Spacer()
//                Button(action: { showNewContactForm = true }) {
//                    Text("Add Contact")
//                        .font(.system(size: 15, weight: .bold))
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.red)
//                        .cornerRadius(10)
//                }
//                .sheet(isPresented: $showNewContactForm) {
//                    NewEmergencyContactForm(showForm: $showNewContactForm, viewModel: emergencyInfoViewModel, userID: authViewModel.user_id ?? "80003")
//                }
//            }
//            .padding()

            Text("Emergency Contacts")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .foregroundColor(ourOrange)
                .padding()
                .padding(.top)
            ZStack{
                creamColor.edgesIgnoringSafeArea(.all)
                
                
                List {
                    Section(header: Text("Your Contacts")
                        .font(.system(size:16, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.top, 5)) {
                        if emergencyInfoViewModel.userContacts.isEmpty {
                            Text("No emergency contacts yet.")
                                .foregroundColor(.black)
                        } else {
                            ForEach(emergencyInfoViewModel.userContacts) { contact in
                                ContactRow(contact: contact)
                            }
                            .onDelete { indexSet in
                                deleteContact(from: indexSet, in: &emergencyInfoViewModel.userContacts)
                            }
                        }
                        Button(action: { showNewContactForm = true }) {
                                Text("Add Contact")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(7)
                                    .background(ourRed)
                                    .cornerRadius(10)
                            } //button
                            .sheet(isPresented: $showNewContactForm) {
                                NewEmergencyContactForm(showForm: $showNewContactForm, viewModel: emergencyInfoViewModel, userID: authViewModel.user_id ?? "80003")
                            }
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 4)
                            .padding(7)

                    } // Your contacts section
                        

                    
                    Section(header: Text("Roommate's Contacts")
                        .font(.system(size:16, weight: .medium))
                        .foregroundColor(.black)) {
                        if emergencyInfoViewModel.roommateContacts.isEmpty {
                            Text("No contacts found for your roommate.")
                                .foregroundColor(.black)
                        } else {
                            ForEach(emergencyInfoViewModel.roommateContacts) { contact in
                                ContactRow(contact: contact)
                            }
                        }
                    }
                    
                } //list
//                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .cornerRadius(10)
//                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 4)
            }//zstack
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 4)
            .padding()
        } //vstack
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
                HStack {
                    Text("Phone:").font(.subheadline)
                    if let phoneURL = URL(string: "tel:\(contact.phoneNumber)") {
                        Link(formatPhoneNumber(contact.phoneNumber), destination: phoneURL)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .underline()
                    } else {
                        Text(formatPhoneNumber(contact.phoneNumber))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Text("Relationship: \(contact.relationship)").font(.footnote).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }
}

func formatPhoneNumber(_ phoneNumber: String) -> String {
    let cleanedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    
    if phoneNumber.hasPrefix("+") || phoneNumber.hasPrefix("00") {
        return formatInternationalNumber(phoneNumber)
    }
    
    switch cleanedNumber.count {
    case 10:
        return "(\(cleanedNumber.prefix(3))) \(cleanedNumber.dropFirst(3).prefix(3))-\(cleanedNumber.suffix(4))"
    case 11 where cleanedNumber.hasPrefix("1"):
        return "+1 (\(cleanedNumber.dropFirst().prefix(3))) \(cleanedNumber.dropFirst(4).prefix(3))-\(cleanedNumber.suffix(4))"
    default:
        return phoneNumber
    }
}

func formatInternationalNumber(_ phoneNumber: String) -> String {
    var formattedNumber = phoneNumber
    if formattedNumber.hasPrefix("00") {
        formattedNumber = "+" + formattedNumber.dropFirst(2)
    }

    let cleanNumber = formattedNumber.filter { $0.isNumber || $0 == "+" }
    var result = ""
    for (index, char) in cleanNumber.enumerated() {
        result.append(char)
        if index > 0 && index % 3 == 0 && index != cleanNumber.count - 1 {
            result.append(" ")
        }
    }

    return result
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
                    .onChange(of: phoneNumber) { newValue in
                        // auto-format as user types
                        phoneNumber = formatPhoneNumber(newValue)
                    }
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
