//
//  AuthenticationViewModel.swift
//  roombee
//
//  Created by Adwait Ganguly on 4/15/24.
//

import Foundation
import FirebaseAuth
import SwiftUI
import AWSLambda

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var in_room = 0
    @Published var is_sleeping = 0
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var birthDate = Date()
    @Published var gender = ""
    @Published var showSignUp = false
    @Published var showLogIn = false
    @Published var isUserSignedIn = true
    @Published var addUserError = false
    @Published var addUserErrorMessage = ""
    @Published var getUserError = false
    @Published var getUserErrorMessage = ""
    @Published var skipCreateOrJoin = false
    
    @Published var flow: AuthenticationFlow = .login
    
    @Published var isValid = false
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage = ""
    @Published var user: User?
    @Published var displayName = ""
    @Published var user_id: String?
    @Published var roommate_id: String?
    @Published var hive_code = ""
    @Published var hive_name = ""
    
    @Published var showingErrorAlert = false
    
    @Published var backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)
    @Published var toggleColor = Color(red: 90 / 255, green: 85 / 255, blue: 77 / 255)
    
    @Published var genderOptions = ["Please select", "Female", "Male", "Other"]
    
    @Published var isUserDataLoaded: Bool = false
    
    init() {
        registerAuthStateHandler()
        
        $flow
            .combineLatest($email, $password, $confirmPassword)
            .map { flow, email, password, confirmPassword in
                flow == .login
                ? !(email.isEmpty || password.isEmpty)
                : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isValid)
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                DispatchQueue.main.async {
                    self.user = user
                    self.authenticationState = user == nil ? .unauthenticated : .authenticated
                    self.displayName = user?.email ?? ""
                }
            }
        }
    }
    
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        showSignUp = (flow == .signUp)
        showLogIn = (flow == .login)
        errorMessage = ""
    }
    
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("Done")
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func reset() {
        flow = .login
        isUserSignedIn = false
        skipCreateOrJoin = false
        authenticationState = .unauthenticated
        email = ""
        password = ""
        confirmPassword = ""
        firstName = ""
        lastName = ""
        birthDate = Date()
        gender = ""
        user = nil
        displayName = ""
        user_id = nil
        roommate_id = nil
        hive_code = ""
        hive_name = ""
        isUserDataLoaded = false
    }
}

// MARK: - Email and Password Authentication

extension AuthenticationViewModel {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            await getUserData()
            return true
        }
        catch  {
            print(error)
            errorMessage = "Incorrect user or password"
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.authenticationState = .unauthenticated
            }
            return false
        }
    }
    
    func validatePassword(_ password: String) -> Bool {
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&#])[A-Za-z\\d@$!%*?&#]{8,}$")
        return passwordRegex.evaluate(with: password)
    }
    
    func signUpWithEmailPassword() async -> Bool {
        
        guard validatePassword(password) else {
           errorMessage = "Does not meet password requirements"
           showingErrorAlert = true
           authenticationState = .unauthenticated
           return false
       }
        
        authenticationState = .authenticating
        do  {
            try await Auth.auth().createUser(withEmail: email, password: password)
            addUserLambda()
            await getUserData()
            return true
        } catch let error as NSError {
            if let authErrorCode = AuthErrorCode.Code(rawValue: error.code) {
                DispatchQueue.main.async {
                        switch authErrorCode {
                    case .emailAlreadyInUse:
                        self.errorMessage = "The email address is already in use."
                    default:
                        self.errorMessage = error.localizedDescription
                    }
                }
            } else {
                    self.errorMessage = error.localizedDescription
            }
                self.authenticationState = .unauthenticated
            }
            showingErrorAlert = true
            return false
        }
    
    
    func signOut(eventStore: EventStore) {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("UserSignedOut"), object: nil)
                
                eventStore.clearEvents()
                
                self.reset()
            }
        }
        catch {
            print(error)
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            DispatchQueue.main.async {
                self.reset()
            }
            return true
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func addUserLambda() {
        let lambdaInvoker = AWSLambdaInvoker.default()
        
        // Create an ISO8601DateFormatter
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        // Format the birthDate to an ISO 8601 string
        let dateString = dateFormatter.string(from: birthDate)
        user_id = UUID().uuidString
        if hive_code == "" {
            hive_code = UUID().uuidString
        }
        
        let jsonObject = [
            "queryStringParameters": ["user_id": user_id, "email": email, "last_name": lastName, "first_name": firstName, "dob": dateString, "hive_code": hive_code, "hive_name": hive_name, "in_room": in_room, "is_sleeping": is_sleeping]
        ] as [String : Any]
        
        lambdaInvoker.invokeFunction("addUser", jsonObject: jsonObject).continueWith { task -> Any? in
            if let error = task.error {
                print("Error occurred: \(error)")
                DispatchQueue.main.async {
                    self.addUserErrorMessage = error.localizedDescription
                    self.addUserError = true
                }
                return nil
            }
            if let result = task.result {
                print("Lambda function result: \(result)")
            }
            return nil
        }
    }
    
    
    // Gets the current user's data from the database that is NOT already in their firebase user
    func getUserData() {
        let lambdaInvoker = AWSLambdaInvoker.default()
        let jsonObject = [
            "queryStringParameters": ["email": email]
        ] as [String : Any]
        
        lambdaInvoker.invokeFunction("getUserData", jsonObject: jsonObject).continueWith { task -> Any? in
            Task { @MainActor in
                if let error = task.error {
                    print("Error occurred: \(error)")
                    DispatchQueue.main.async {
                        self.getUserErrorMessage = error.localizedDescription
                        self.getUserError = true
                    }
                    return nil as Any?
                }
                if let result = task.result as? [String: Any],
                   let bodyString = result["body"] as? String,
                   let data = bodyString.data(using: .utf8) {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let userData = jsonResponse["user_data"] as? [String: Any] {
                                self.hive_code = userData["hive_code"] as? String ?? ""
                                self.user_id = userData["user_id"] as? String ?? ""
                                self.isUserDataLoaded = true
                            }
                            if let roommateData = jsonResponse["roommate_data"] as? [String: Any] {
                                self.roommate_id = roommateData["user_id"] as? String ?? ""
                            }
                        }
                    } catch {
                        self.getUserErrorMessage = error.localizedDescription
                        self.getUserError = true
                    }
                }
                return nil
            }
        }
    }
}

// DateFormatter extension to parse date string
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

