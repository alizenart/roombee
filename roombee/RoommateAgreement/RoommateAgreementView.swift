//
//  RoommateAgreementView.swift
//  roombee
//
//  Created by Ziye Wang on 8/24/24.
//

import SwiftUI

import SwiftUI

struct RoommateAgreementView: View {
    @State private var showNewAgreementForm = false
    @EnvironmentObject var agreementStore: RoommateAgreementStore
    @EnvironmentObject var agreementManager: RoommateAgreementHandler
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    Button(action: { showNewAgreementForm = true }) {
                        Text("Edit")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(height: 25)
                            .background(ourOrange)
                            .cornerRadius(10)
                    }
                    .padding(.trailing)
                    .sheet(isPresented: $showNewAgreementForm) {
                        NewAgreementsForm(showForm: $showNewAgreementForm)
                            .environmentObject(agreementStore)
                    }
                }
                .padding(.top, 20)
                
                Text("Roommate Agreement")
                    .font(.system(size: 30))
                    .foregroundColor(ourOrange)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                Text("The purpose of this agreement is to establish some expectations to make the shared living experience positive for all people involved.")
                    .fontWeight(.bold)
                    .font(.system(size: 12))
                    .foregroundColor(creamColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack {
                    HStack {
                        Text("Rules")
                            .foregroundColor(creamColor)
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                            .padding(.leading)
                            .padding(.top)
                        Spacer()
                    }

                    // Swipe-to-delete list for rules
                    if agreementStore.agreements.isEmpty {
                        Text("No rules yet. Click edit to add a rule for your living arrangement.")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.4, alignment: .center)  // Ensure it takes up space
                    } else {
                        List {
                            ForEach(agreementStore.agreements.filter { $0.isRule }) { agreement in
                                AgreementView(agreement: agreement, cardWidth: UIScreen.main.bounds.width * 0.9)
                                    .padding(.vertical, 5)
                                
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                            .onDelete { indexSet in
                                   for index in indexSet {
                                       let agreement = agreementStore.agreements[index]
                                       agreementStore.agreements.removeAll { $0.id == agreement.id }
                                       agreementManager.deleteAgreement(agreementID: agreement.id)
                                   }
                               }
                        }
                        .scrollContentBackground(.hidden)
                        .frame(maxHeight: geometry.size.height * 0.4)  // Restrict the height to half
                    }
                }
                .frame(height: geometry.size.height * 0.4)  // Ensure the entire VStack takes up half
                
                VStack {
                    HStack {
                        Text("Community & Personal Items")
                            .foregroundColor(creamColor)
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                            .padding(.leading)
                            .padding(.top)
                        Spacer()
                    }

                    // Swipe-to-delete list for community and personal items
                    if agreementStore.items.isEmpty {
                        Text("No community items yet. Click edit to add a community or personal item for your living arrangement.")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.4, alignment: .center)  // Ensure it takes up space
                    } else {
                        List {
                            ForEach(agreementStore.items) { agreement in
                                AgreementView(agreement: agreement, cardWidth: UIScreen.main.bounds.width * 0.9)
                                    .padding(.vertical, 5)
                                
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                            .onDelete { indexSet in
                                   for index in indexSet {
                                       let agreement = agreementStore.items[index]
                                       agreementStore.items.removeAll { $0.id == agreement.id }
                                       agreementManager.deleteAgreement(agreementID: agreement.id)
                                   }
                               }
                        }
                        .scrollContentBackground(.hidden)
                        .frame(maxHeight: geometry.size.height * 0.4)  // Restrict the height to half
                    }
                }
                .frame(height: geometry.size.height * 0.4)  // Ensure the entire VStack takes up half
                
                Spacer()
            }
            .onAppear {
                fetchAgreements()
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                    fetchAgreements()
                }
            }
        }
    }

    private func fetchAgreements() {
        agreementManager.fetchAllAgreements(user_id: "80002", roommate_id: "80003")
        let all_agreements = agreementManager.userAgreements + agreementManager.roommateAgreements
        let new_agreements = all_agreements.filter { agreement in
            !agreementStore.agreements.contains(where: {$0.id == agreement.id}) && !agreementStore.items.contains(where: {$0.id == agreement.id})
        }
        agreementStore.agreements.append(contentsOf: new_agreements.filter { $0.isRule })
        agreementStore.items.append(contentsOf: new_agreements.filter { !$0.isRule })
    }
}

//struct RoommateAgreementView: View {
//    @State private var showNewAgreementForm = false
//    @EnvironmentObject var agreementStore: RoommateAgreementStore
//    @EnvironmentObject var agreementManager: RoommateAgreementHandler
//    @State private var timer: Timer?
//    
//    var body: some View {
//        GeometryReader { geometry in
//            VStack {
//                HStack {
//                    Spacer()
//                    Button(action: { showNewAgreementForm = true }) {
//                        Text("Edit")
//                            .font(.system(size: 15, weight: .bold))
//                            .foregroundColor(.white)
//                            .padding()
//                            .frame(height: 25)
//                            .background(ourOrange)
//                            .cornerRadius(10)
//                    }
//                    .padding(.trailing)
//                    .sheet(isPresented: $showNewAgreementForm) {
//                        NewAgreementsForm(showForm: $showNewAgreementForm)
//                            .environmentObject(agreementStore)
//                    }
//                }
//                .padding(.top, 20)
//                
//                Text("Roommate Agreement")
//                    .font(.system(size: 30))
//                    .foregroundColor(ourOrange)
//                    .fontWeight(.bold)
//                    .padding(.top, 10)
//                Text("The purpose of this agreement is to establish some expectations to make the shared living experience positive for all people involved.")
//                    .fontWeight(.bold)
//                    .font(.system(size: 12))
//                    .foregroundColor(creamColor)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                
//                HStack {
//                    Text("Rules")
//                        .foregroundColor(creamColor)
//                        .font(.system(size: 22))
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.leading)
//                        .padding(.leading)
//                        .padding(.top)
//                    Spacer()
//                }
//                
//                // Swipe-to-delete list for rules
//                if agreementStore.agreements.isEmpty {
//                    Text("No rules yet. Click edit to add a rule for your living arrangement.")
//                        .foregroundColor(.gray)
//                        .font(.system(size: 12))
//                        .multilineTextAlignment(.center)
//                        .padding(.top, 10)
//                        .padding(.horizontal)
//                } else {
//                    List {
//                        ForEach(agreementStore.agreements.filter { $0.isRule }) { agreement in
//                            AgreementView(agreement: agreement, cardWidth: UIScreen.main.bounds.width * 0.9)
//                                .padding(.vertical, 5)
//                            
//                                .listRowSeparator(.hidden)
//                                .listRowBackground(Color.clear)
//                        }
//                        .onDelete { indexSet in
//                            for index in indexSet {
//                                let agreement = agreementStore.agreements[index]
//                                agreementStore.agreements.removeAll { $0.id == agreement.id }
//                                agreementManager.deleteAgreement(agreementID: agreement.id)
//                            }
//                        }
//                    }
//                    .scrollContentBackground(.hidden)
//                    .frame(maxHeight: geometry.size.height * 0.4)
//                }
//            }
//            .frame(height: geometry.size.height * 0.4)
//            VStack {
//                HStack {
//                    Text("Community & Personal Items")
//                        .foregroundColor(creamColor)
//                        .font(.system(size: 22))
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.leading)
//                        .padding(.leading)
//                        .padding(.top)
//                    Spacer()
//                }
//                
//                // Swipe-to-delete list for community and personal items
//                if agreementStore.items.isEmpty {
//                    Text("No community items yet. Click edit to add a community or personal item for your living arrangement.")
//                        .foregroundColor(.gray)
//                        .font(.system(size: 12))
//                        .multilineTextAlignment(.center)
//                        .padding(.top, 10)
//                        .padding(.horizontal)
//                } else {
//                    List {
//                        ForEach(agreementStore.items) { agreement in
//                            AgreementView(agreement: agreement, cardWidth: UIScreen.main.bounds.width * 0.9)
//                                .padding(.vertical, 5)
//                            
//                                .listRowSeparator(.hidden)
//                                .listRowBackground(Color.clear)
//                        }
//                        .onDelete { indexSet in
//                            for index in indexSet {
//                                let agreement = agreementStore.items[index]
//                                agreementStore.items.removeAll { $0.id == agreement.id }
//                                agreementManager.deleteAgreement(agreementID: agreement.id)
//                            }
//                        }
//                    }
//                    .scrollContentBackground(.hidden)
//                    .frame(maxHeight: geometry.size.height * 0.4)
//                    
//                }
//            }
//                .frame(height: geometry.size.height * 0.4)  // Ensure the entire VStack takes up half
//                
//                Spacer()
//            }
//        .onAppear {
//            fetchAgreements()
//            timer?.invalidate()
//            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//                fetchAgreements()
//            }
//        }
//    }
//
//    private func fetchAgreements() {
//            agreementManager.fetchAllAgreements(user_id: "80002", roommate_id: "80003")
//        agreementStore.agreements =  (agreementManager.userAgreements + agreementManager.roommateAgreements).filter { $0.isRule }
//        agreementStore.items = (agreementManager.userAgreements + agreementManager.roommateAgreements).filter { !$0.isRule }
//        }
//    
//
//}



// Form for new agreements. Triggered when user presses 'Edit'
struct NewAgreementsForm: View {
    @EnvironmentObject var agreementStore: RoommateAgreementStore
    @EnvironmentObject var agreementManager: RoommateAgreementHandler
    @Binding var showForm: Bool
    @State private var isRule = true
    
    @State private var title = ""
    @State private var dateCreated = Date()

    @State private var tags: [String] = []
    
    @State private var itemOwner = ""
    @State private var whoCanUse = ""
    @State private var itemDetails = ""
    
    private let ruleTags = ["Chores", "Prohibitions"]
    private let owners = ["Roommate1", "Roommate2"]
    private let whoIsAbletoUse = ["Roommate1 Only", "Roommate2 Only", "Everyone"]

    
    var body: some View {
        NavigationView {
            Form {
                Picker("Type", selection: $isRule) {
                    Text("Add Item").tag(false)
                    Text("Add Rule").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())

                if isRule {
                    TextField("Rule Description", text: $title)
                    /*dateCreated = Date()*/ // the variable date Created should be the current date and time
                    DropdownView(title: "Select Tags", prompt: "None", options: ruleTags, selection: $tags)
                }
                else {
                    TextField("Item", text: $title)
                    SingleSelectionDropdownView(title: "Owner", prompt: "None", options: owners, selection: $itemOwner)
                    SingleSelectionDropdownView(title: "Who Can Use", prompt: "None", options: whoIsAbletoUse, selection: $whoCanUse)
                    TextField("Details", text: $itemDetails)

                }
            }
            .navigationBarTitle("New Agreement", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                showForm = false
            }, trailing: Button("Post") {
                let new_id = UUID().uuidString
                let newAgreement = Agreement(
                    id: new_id,
                    title: title,
                    dateCreated: dateCreated,
                    isRule: isRule,
                    
                    tags: tags.isEmpty ? nil : tags,
                                        
                    //items
                    itemOwner: itemOwner,
                    whoCanUse: whoCanUse,
                    itemDetails: itemDetails
                )
                let date_string = format(date:newAgreement.dateCreated)
                agreementManager.addAgree(id: newAgreement.id, title: newAgreement.title, dateCreated: date_string, isRule: isRule ? "0" : "1", tags: tags.joined(separator: ","), itemOwner: "80003", whoCanUse: "80003", itemDetails: itemDetails)
                agreementStore.addAgreement(newAgreement)
            
                showForm = false
            })
        }
    }
    private func format(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from:date)
    }
}

// Renders the post in the AnnouncementsPage screen. The code for the cream colored posts view
struct AgreementView: View {
    var agreement: Agreement
    var cardWidth: CGFloat
    
    let tagColors: [String: Color] = [
        "Chores": .blue,
        "Prohibitions": .red
    ]

    var body: some View {
        VStack(alignment: .leading) {
            
            // if the agreement is a rule, this is the post's view
            if agreement.isRule {
                Text(agreement.title)
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(backgroundColor)
                Text("Date created: \(agreement.dateCreated, style: .date)")
                    .foregroundColor(.gray)
//                    .font(.subheadline)
                    .font(.system(size:10, weight: .light))

                if let tags = agreement.tags {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.footnote)
                                .fontWeight(.bold)
                                .padding(.top, 1)
                                .padding(.bottom, 1)
                                .padding(.horizontal, 2)
                                .foregroundColor(.white)
                                .background(tagColors[tag] ?? Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                    }
                    .padding(.top, 5)
                }
            } 
            // if the agreement is an item, this is the post's view
            else {
                Text(agreement.title)
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(backgroundColor)
                
                if let itemOwner = agreement.itemOwner {
                    HStack{
                        Text("Owner: ")
//                            .font(.subheadline)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(backgroundColor)
                        Text(itemOwner)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(ourOrange)
                    }
                }
                
                if let whoCanUse = agreement.whoCanUse {
                    HStack{
                        Text("Who Can Use: ")
//                            .font(.subheadline)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(backgroundColor)
                        Text(whoCanUse)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(ourOrange)
                    }
//                    .padding(.top, 2)
                }
                
                if let itemDetails = agreement.itemDetails {
                    Text("Details: \(itemDetails)")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    //                        .padding(.top, 2)
                }

            }
        }
        .padding()
        .frame(width: cardWidth, alignment: .leading)
        .background(creamColor)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}



extension DateFormatter {
    static let fullDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}


#Preview {
    RoommateAgreementView()
}
