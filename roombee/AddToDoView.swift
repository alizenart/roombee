////
////  AddToDoView.swift
////  roombee
////
////  Created by Nicole Liu on 4/15/24.
////
//
//import SwiftUI
//
//
//struct AddToDoView: View {
//    @State
//    private var newToDo = Task(title:"")
//    var onCommit: (_ newToDo: Task) -> Void
//    
//    @Environment(\.dismiss)
//    private var dismiss
//    
//    enum FocusableField: Hashable {
//        case title}
//
//    @FocusState
//    private var focusedField: FocusableField?
//
//    private func add() {
//        onCommit(newToDo)
//        dismiss()
//    }
//    
//    private func cancel() {
//        dismiss()
//    }
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                TextField("Title", text: $newToDo.title)
//                    .focused($focusedField, equals: .title)
//            }
//            .navigationTitle("New Reminder")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button(action: cancel) {
//                        Text("Cancel")
//                    }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button(action: add) {
//                        Text("Add")}
//                    .disabled(newToDo.title.isEmpty)
//                }
//            }
//            .onAppear {
//                focusedField = .title
//            }
//        }
//    }
//}
//
//struct AddReminderView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddToDoView { todo in
//            print("You added a new reminder titled \(todo.title)")
//        }
//    }
//}

//
//  AddToDoView.swift
//  roombee
//
//  Created by Nicole Liu on 4/15/24.
//

import SwiftUI


struct AddToDoView: View {
    @State
    var newToDo = Tasks(title:"", priority:.low, category: .none)
    var onCommit: (_ newToDo: Tasks) -> Void
    let options = ["low", "medium", "urgent"]
    @State
    private var selectedOption = 0
    
    @Environment(\.dismiss)
    private var dismiss
    
    enum FocusableField: Hashable {
        case title}

    @FocusState
    private var focusedField: FocusableField?

    private func add() {
        onCommit(newToDo)
        dismiss()
    }
    
    private func cancel() {
        dismiss()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                Form {
                    TextField("Title", text: $newToDo.title)
                        .focused($focusedField, equals: .title)
                    Section(header: Text("Priority")) {
                        Picker(selection: $selectedOption, label: Text("")) {
                            ForEach(0..<3) { index in
                                Text(self.options[index]).tag(index)
                                    .frame(minHeight: 50, alignment: .center)
                            }
                        }
                    }
                    .onChange(of: selectedOption) { newValue in
                        switch newValue {
                        case 0:
                            newToDo.priority = .low
                        case 1:
                            newToDo.priority = .medium
                        case 2:
                            newToDo.priority = .high
                        default:
                            break
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("New Reminder")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: cancel) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: add) {
                            Text("Add")}
                        .disabled(newToDo.title.isEmpty)
                    }
                }
                .onAppear {
                    focusedField = .title
                }
            }
        }
    }
}

struct AddReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AddToDoView { todo in
            print("You added a new reminder titled \(todo.title)")
        }
    }
}
