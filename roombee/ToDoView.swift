import SwiftUI

struct ToDoView: View {
    @EnvironmentObject var todoManager: TodoViewModel
    @EnvironmentObject var auth: AuthenticationViewModel
    @State private var tasks = Tasks.samples
    @State
    private var addpresent = false
    @State private var timer:Timer?
    let myUserId = "80003"
    let roomieUserId = "80002"
    @State private var deletedTasks: Set<String> = []
    
    private func addview() {
        addpresent.toggle()
    }
    
    var body: some View {
        NavigationView { 
            ZStack {
                
                backgroundColor
                    .ignoresSafeArea()
                VStack {
                    Text("Tasks")
                        .font(.largeTitle)
                        .foregroundColor(ourOrange)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    
                    List {
                        // $ used for binding
                        ForEach($tasks, id: \.self) {$task in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 230 / 255, green: 217 / 255, blue: 197 / 255))
                                .frame(height: 65)
                                .overlay(
                                    HStack {
                                        Image(systemName: task.status != 0
                                              ? "largecircle.fill.circle"
                                              : "circle")
                                        .imageScale(.large)
                                        .foregroundColor(.accentColor)
                                        .onTapGesture {
                                            task.status = task.status == 0 ? 1 : 0
                                            todoManager.updateTodo(todoID: task.id, todoStatus: String(task.status));
                                        }
                                        Text(task.todoTitle)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(backgroundColor)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(categoryColor(for: task.todoPriority))
                                            .frame(width: 50, height: 30)
                                            .overlay(Text(task.todoCategory))
                                        
                                    }
                                        .padding()
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            
                        }
                        // $ for wrapping
                        .onDelete { indexSet in
                            if let index = indexSet.first {
                                let deletedtask = $tasks.wrappedValue[index]
                                deletedTasks.insert(deletedtask.id)
                                $tasks.wrappedValue.remove(atOffsets: indexSet)
                                todoManager.deleteTodo(todoID: deletedtask.id)
                                
                            }
                        }
                    } // List
                    .scrollContentBackground(.hidden)
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            Button(action: addview) {
                                ZStack {
                                    hexagonShape()
                                        .fill(Color(red: 221 / 255, green: 132 / 255, blue: 67 / 255))
                                        .frame(width: 50, height: 60)
                                    Text("+")
                                        .foregroundColor(.white)
                                        .fontWeight(.heavy
                                        )
                                        .font(.system(size: 45
                                                     ))
                                        .padding(.bottom, 5)
                                }
                            }
                            Spacer()
                        }
                    }// toolbar
                    // appending new task to list
                    .sheet(isPresented: $addpresent) {
                        AddToDoView { task in
                            tasks.append(task)
                            todoManager.addToDo(todoID: task.id,
                                                userId: auth.user_id ?? "80003",
                                                hiveCode: auth.hive_code,
                                                todoTitle: task.todoTitle,
                                                todoPriority: task.todoPriority,
                                                todoCategory: task.todoCategory,
                                                todoStatus: String(task.status))
                        }
                    }// sheet
                }//vstack
            }//zstack
        }
        .onAppear {
            fetchAllTasks()
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                fetchAllTasks()
            }
        }// nav view
        
    }// body
    
    // filter to check if any local tasks are not in the polled tasks
    private func fetchAllTasks() {
       guard let userId = auth.user_id, let roommateId = auth.roommate_id else {
           print("No user ID or roommate ID found.")
           return
       }
       
       todoManager.fetchAllTasks(user_id: userId, roommate_id: roommateId)

        let combinedTasks = todoManager.userTasks + todoManager.roommateTasks

        // Filter and add tasks that don't already exist in the tasks list
        let newTasks = combinedTasks.filter { task in
            !deletedTasks.contains(task.id) &&
            !tasks.contains(where: { $0.id == task.id })
        }

        // Append new unique tasks
        tasks.append(contentsOf: newTasks)
   }

}



func priorityColor(for priority: String) -> Color {
    switch priority {
    case "low":
        return Color.green
    case "med":
        return Color.yellow
    case "high":
        return Color.red
    default:
        return Color.red // Default color if priority is not recognized
    }
}

func priorityValue(for priority: todoPriority) -> Int {
    switch priority {
    case .high:
        return 0
    case .medium:
        return 1
    case .low:
        return 2
    }
}

func categoryColor(for category: todoCategory) -> Int {
    switch category {
    case .none:
        return 0
    case .shopping:
        return 1
    case .chores:
        return 2
    }
}

func categoryColor(for category: String) -> Color {
    switch category {
    case "none":
        return Color.blue
    case "shopping":
        return Color.orange
    case "chores":
        return Color.mint
    default:
        return Color.indigo
    }
}




struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoView()
    }
}
