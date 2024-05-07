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
    
  @Published var firstName = ""
  @Published var lastName = ""
  @Published var birthDate = Date()
  @Published var gender = ""
  @Published var showSignUp = false
  @Published var showLogIn = false
  @Published var isUserSignedIn = true


  @Published var flow: AuthenticationFlow = .login

  @Published var isValid = false
  @Published var authenticationState: AuthenticationState = .unauthenticated
  @Published var errorMessage = ""
  @Published var user: User?
  @Published var displayName = ""
  @Published var user_id = UUID().uuidString
  @Published var hive_code: String? = "nil"
    
  @Published var backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)
  @Published var toggleColor = Color(red: 90 / 255, green: 85 / 255, blue: 77 / 255)
    
  @Published var genderOptions = ["Female", "Male", "Other"]
    
  init() {
    registerAuthStateHandler()

    $flow
      .combineLatest($email, $password, $confirmPassword)
      .map { flow, email, password, confirmPassword in
        flow == .login
          ? !(email.isEmpty || password.isEmpty)
          : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
      }
      .assign(to: &$isValid)
  }

  private var authStateHandler: AuthStateDidChangeListenerHandle?

  func registerAuthStateHandler() {
    if authStateHandler == nil {
      authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
        self.user = user
        self.authenticationState = user == nil ? .unauthenticated : .authenticated
        self.displayName = user?.email ?? ""
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
    email = ""
    password = ""
    confirmPassword = ""
  }
}

// MARK: - Email and Password Authentication

extension AuthenticationViewModel {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            return true
        }
        catch  {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }

    func signUpWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do  {
            try await Auth.auth().createUser(withEmail: email, password: password)
            invokeLambdaFunction()
            return true
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }

  func signOut() {
    do {
      try Auth.auth().signOut()
      isUserSignedIn = false
      switchFlow()
    }
    catch {
      print(error)
      errorMessage = error.localizedDescription
    }
  }

  func deleteAccount() async -> Bool {
    do {
      try await user?.delete()
      return true
    }
    catch {
      errorMessage = error.localizedDescription
      return false
    }
  }
    
  func invokeLambdaFunction() {
      let lambdaInvoker = AWSLambdaInvoker.default()
      
      // Create an ISO8601DateFormatter
      let dateFormatter = ISO8601DateFormatter()
      dateFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
      
      // Format the birthDate to an ISO 8601 string
      let dateString = dateFormatter.string(from: birthDate)
      
      let jsonObject = [
        "queryStringParameters": ["user_id": user_id, "email": email, "last_name": lastName, "first_name": firstName, "dob": dateString, "hive_code": hive_code ?? "", "password_hash": password]
      ] as [String : Any]
      
      lambdaInvoker.invokeFunction("addUser", jsonObject: jsonObject).continueWith { task -> Any? in
          if let error = task.error {
              print("Error occurred: \(error)")
              return nil
          }
          if let result = task.result {
              print("Lambda function result: \(result)")
          }
          return nil
      }
  }
}
