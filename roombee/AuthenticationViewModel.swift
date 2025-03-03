//
//  AuthenticationViewModel.swift
//  roombee
//
//  Created by Adwait Ganguly on 4/15/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import SwiftUI
import AWSLambda
import Mixpanel
import AWSS3
import AWSCore
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit


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
    @Published var isUserSignedIn = false
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
    
    @Published var user_firstName = ""
    @Published var user_lastName = ""
    @Published var roommate_firstName = ""
    @Published var roommate_lastName = ""
    
    
    @Published var profileImageURL: String? = nil

    @Published var roommateProfileImageURL: String? = nil
    
    @Published var showingErrorAlert = false
    
    @Published var backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)
    @Published var toggleColor = Color(red: 90 / 255, green: 85 / 255, blue: 77 / 255)
    
    @Published var genderOptions = ["Please select", "Female", "Male", "Other", "Prefer Not To Say"]
    
    @Published var isUserDataLoaded: Bool = false
    
    
    //onboardGuide struggles
    @Published var shouldNavigateToHomepage = false
    
    //Used for Apple SignIn
    @Published var currentNonce: String?


    
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
                    if let user = user {
                        print("User logged in: \(user.email ?? "No email")")
                        self.email = user.email ?? ""
                        self.authenticationState = .authenticated // User is logged in
                    } else {
                        print("No user logged in")
                        self.authenticationState = .unauthenticated // No user logged in
                    }
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
        showSignUp = false
        showLogIn = false
        addUserError = false
        addUserErrorMessage = ""
        getUserError = false
        getUserErrorMessage = ""
        
        // Reset state-specific properties
        isValid = false
        errorMessage = ""
        user = nil
        displayName = ""
        user_id = nil
        roommate_id = nil
        hive_code = ""
        hive_name = ""
        
        user_firstName = ""
        user_lastName = ""
        roommate_firstName = ""
        roommate_lastName = ""
        
        profileImageURL = nil
        roommateProfileImageURL = nil
        
        showingErrorAlert = false
        
        backgroundColor = Color(red: 56 / 255, green: 30 / 255, blue: 56 / 255)
        toggleColor = Color(red: 90 / 255, green: 85 / 255, blue: 77 / 255)
        
        genderOptions = ["Please select", "Female", "Male", "Other", "Prefer Not To Say"]
        
        isUserDataLoaded = false
        shouldNavigateToHomepage = false
        
        // Reset Apple SignIn data
        currentNonce = nil
    }

}

// MARK: - Email and Password Authentication

extension AuthenticationViewModel {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            // Check if the email has a valid password sign-in method
            let signInMethods = try await Auth.auth().fetchSignInMethods(forEmail: self.email)
            print("Sign-in methods for \(self.email): \(signInMethods)")

            if !signInMethods.contains("password") {
                // The account exists but is not associated with email/password
                DispatchQueue.main.async {
                    if signInMethods.contains("google.com") {
                        self.errorMessage = "Your account is registered with Google. Please use 'Sign in with Google'."
                    } else if signInMethods.contains("apple.com") {
                        self.errorMessage = "Your account is registered with Apple. Please use 'Sign in with Apple'."
                    } else {
                        self.errorMessage = "This account is registered with another sign-in method."
                    }
                    self.showingErrorAlert = true
                }
                authenticationState = .unauthenticated
                return false
            }

            // Attempt email/password sign-in
            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            await getUserData()
            DispatchQueue.main.async {
                self.authenticationState = .authenticated // Update state here
            }
            Mixpanel.mainInstance().track(event: "User Signed In", properties: [
                "userId": user_id ?? "Unknown",
                "email": email
            ])
            return true
        } catch {
            print("Error signing in with email/password: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Incorrect email or password. Please try again."
                self.authenticationState = .unauthenticated
            }
            Mixpanel.mainInstance().track(event: "Sign-In Error", properties: [
                "error": error.localizedDescription
            ])
            return false
        }
    }

    
    func validatePassword(_ password: String) -> Bool {
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d\\W]{8,}$")
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
            authenticationState = .authenticated
            Mixpanel.mainInstance().track(event: "User Signed Up", properties: [
                            "userId": user?.uid ?? "Unknown",
                            "email": email
                        ])
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
            showingErrorAlert = true
            Mixpanel.mainInstance().track(event: "Sign-Up Error", properties: [
                            "error": error.localizedDescription
                        ])
            return false
        }
    }
    
    
    func signOut(eventStore: EventStore) {
        do {
            try Auth.auth().signOut()
            Mixpanel.mainInstance().track(event: "User Signed Out", properties: [
                        "userId": user?.uid ?? "Unknown",
                        "email": email
                    ])
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("UserSignedOut"), object: nil)
                
                eventStore.clearEvents()
                
                self.reset()
                self.authenticationState = .unauthenticated
                
            }
        }
        catch {
            print(error)
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            Mixpanel.mainInstance().track(event: "Sign-Out Error", properties: [
                        "error": error.localizedDescription
                    ])
        }
    }
    
    func deleteAccount(withPassword password: String) async -> Bool {
        do {
            // Reauthenticate the user before deletion
            guard let user = user else {
                print("No user is currently signed in.")
                return false
            }
            
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            try await user.reauthenticate(with: credential)
            Mixpanel.mainInstance().track(event: "Account Deleted", properties: [
                "userId": user_id ?? "Unknown",
                        "email": email
                    ])
            print("User reauthenticated successfully")
            
            // Attempt to delete the user from Firebase
            try await user.delete()
            print("User deleted successfully from Firebase")
            
            // Delete user from backend (Lambda)
            deleteAccountLambda()
            
            // Reset and return success
            DispatchQueue.main.async {
                self.reset()
                self.authenticationState = .unauthenticated
            }
            
            return true
            
        } catch {
            print("Error deleting account: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                Mixpanel.mainInstance().track(event: "Account Deletion Error", properties: [
                            "error": error.localizedDescription
                        ])
            }
            return false
        }
    }

    func generateShorterUUID() -> String {
        let uuid = UUID().uuidString
        // Shorten to the first 8 characters for example
        let shortUUID = String(uuid.prefix(12))
        return shortUUID
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
            hive_code = generateShorterUUID()
        }
        
        guard let fcmToken = TokenManager.shared.fcmToken else {return}
                let jsonObject = [
                    "queryStringParameters": ["user_id": user_id, "email": email, "last_name": lastName, "first_name": firstName, "dob": dateString, "hive_code": hive_code, "hive_name": hive_name, "in_room": in_room, "is_sleeping": is_sleeping, "sns_endpoint_arn": fcmToken ?? ""]
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
                self.getUserData()
            }
            return nil
        }
    }
    
    func deleteAccountLambda() {
        let lambdaInvoker = AWSLambdaInvoker.default()
        
        guard let user_id = user_id else {
            print("No user_id found, cannot proceed with deletion.")
            return
        }
        
        let jsonObject = [
            "queryStringParameters": ["user_id": user_id]
        ] as [String : Any]
        
        lambdaInvoker.invokeFunction("deleteAccount", jsonObject: jsonObject).continueWith { task -> Any? in
            if let error = task.error {
                print("Error occurred: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
                return nil
            }
            if let result = task.result {
                print("Lambda function result: \(result)")
                DispatchQueue.main.async {
                    self.reset()
                    self.showingErrorAlert = false
                }
            }
            return nil
        }
    }
    
    
    func updateProfilePictureURL(s3Url: String) {
        self.profileImageURL = s3Url
        let lambdaInvoker = AWSLambdaInvoker.default()
        
        let jsonObject = [
            "queryStringParameters": [
                "user_id": user_id,
                "profile_picture_url": s3Url
            ]
        ] as [String: Any]
        
        lambdaInvoker.invokeFunction("updateProfilePicture", jsonObject: jsonObject).continueWith { task -> Any? in
            if let error = task.error {
                print("Error occurred: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
                return nil
            }
            if let result = task.result {
                print("Lambda function result: \(result)")
                DispatchQueue.main.async {
                    self.showingErrorAlert = false
                }
            }
            return nil
        }
    }
    
    func addToken() {
            let lambdaInvoker = AWSLambdaInvoker.default()
            
            
            guard let fcmToken = TokenManager.shared.fcmToken else {return}
                    let jsonObject = [
                        "queryStringParameters": ["user_id": self.user_id, "sns_endpoint_arn": fcmToken ?? ""]
                    ] as [String : Any]
            
            lambdaInvoker.invokeFunction("updateToken", jsonObject: jsonObject).continueWith { task -> Any? in
                if let error = task.error {
                    print("Error occurred: \(error)")
                    return nil
                }
                if let result = task.result {
                    print("Lambda function result: \(result)")
                    self.getUserData()
                }
                return nil
            }
        }
    
    
    // Gets the current user's data from the database that is NOT already in their firebase user
    func getUserData() {
        print("getUserData called")
        let lambdaInvoker = AWSLambdaInvoker.default()
        let jsonObject = [
            "queryStringParameters": ["email": email]
        ] as [String : Any]
        print("lambda function calling with this email \(email)")
        
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
                print("in task")
                if let result = task.result as? [String: Any] {
                print("Lambda invocation result: \(result)")  // Log the entire result
                if let bodyString = result["body"] as? String {
                    print("Body string from Lambda: \(bodyString)")
                    if let data = bodyString.data(using: .utf8) {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                print("JSON response: \(jsonResponse)")  // Log the parsed JSON response
                                
                                if let userData = jsonResponse["user_data"] as? [String: Any] {
                                    self.hive_code = userData["hive_code"] as? String ?? ""
                                    self.user_id = userData["user_id"] as? String ?? ""
                                    self.isUserDataLoaded = true
                                    self.user_firstName = userData["first_name"] as? String ?? ""
                                    self.user_lastName = userData["last_name"] as? String ?? ""
                                    self.profileImageURL = userData["profile_picture_url"] as? String ?? ""
                                    
                                    if let snsEndpointArn = userData["sns_endpoint_arn"] as? String {
                                                if snsEndpointArn == "<null>" {
                                                    self.addToken()
                                                }
                                            } else if userData["sns_endpoint_arn"] is NSNull || userData["sns_endpoint_arn"] == nil {
                                                self.addToken()
                                            }
                                    print("User data loaded: \(userData)")
                                    
                                }
                                
                                if let roommateData = jsonResponse["roommate_data"] as? [String: Any] {
                                    self.isUserDataLoaded = true
                                    self.roommate_id = roommateData["user_id"] as? String ?? ""
                                    self.roommate_firstName = roommateData["first_name"] as? String ?? ""
                                    self.roommate_lastName = roommateData["last_name"] as? String ?? ""
                                    self.roommateProfileImageURL = roommateData["profile_picture_url"] as? String ?? ""
                                    print("Roommate data loaded: \(roommateData)")
                                }
                            }
                        } catch {
                            print("JSON parsing error: \(error)")
                            self.getUserErrorMessage = error.localizedDescription
                            self.getUserError = true
                        }
                    } else {
                        print("Failed to convert bodyString to Data")
                    }
                } else {
                    print("Body not found in Lambda response")
                }
            } else {
                print("No result from Lambda invocation")
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

extension AuthenticationViewModel {
    func isEmailAlreadyInUse(email: String) async -> Bool {
        // Normalize the email by trimming spaces and converting to lowercase
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        print("Checking if email is already in use: \(normalizedEmail)")

        do {
            let signInMethods = try await Auth.auth().fetchSignInMethods(forEmail: normalizedEmail)
            print("Sign-in methods: \(signInMethods)")  // Debugging: print the sign-in methods result
            let isInUse = !signInMethods.isEmpty
            print("Email is \(isInUse ? "already" : "not") in use.")
            return isInUse
        } catch {
            print("Error checking email: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showingErrorAlert = true
            return false
        }
    }
    
}


//Sign In with Google and Apple
extension AuthenticationViewModel {
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random % UInt8(charset.count))])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("No clientID found")
            return false
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root controller")
            return false
        }
        
        do {
            // Perform Google sign-in
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            
            guard let idToken = user.idToken else {
                print("ID token missing")
                return false
            }
            
            let email = user.profile?.email ?? ""
            let accessToken = user.accessToken
            
            // Check existing sign-in methods for the email
            let signInMethods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            print("Sign-in methods for \(email): \(signInMethods)")
            
            if !signInMethods.isEmpty && !signInMethods.contains("google.com") {
                // Email already registered with a different method
                DispatchQueue.main.async {
                    self.errorMessage = "Your account is already registered with email/password. Please use that to sign in."
                    self.showingErrorAlert = true
                }
                return false
            }
            
            // Proceed with Google sign-in
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
            
            // Extract user details
            self.firstName = user.profile?.givenName ?? ""
            self.lastName = user.profile?.familyName ?? ""
            self.profileImageURL = user.profile?.imageURL(withDimension: 200)?.absoluteString
            
            // Add user to backend
            addUserLambda()
            
            return true
        } catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            self.showingErrorAlert = true
            return false
        }
    }
    
    
    func handleSignInWithApple(_ authResults: ASAuthorization) {
        print("in sign in with apple")
        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

            Task {
                do {
                    print("in task")
                    // Extract email if available
                    let authResult = try await Auth.auth().signIn(with: credential)
                    
                    let firebaseUser = authResult.user
                                    
                    // Use Firebase User email or the one from Apple credential
                    let email = firebaseUser.email ?? appleIDCredential.email ?? ""
                    print("User signed in with email: \(email)")
                    print("email: \(email)")

                    // Check if email is already in use with a different sign-in method (e.g., Google)
                    let signInMethods = try await Auth.auth().fetchSignInMethods(forEmail: email)
                    print("Sign-in methods for \(email): \(signInMethods)")

                    if !signInMethods.isEmpty {
                        // If email is already linked with Google, allow linking with Apple
                        if signInMethods.contains("google.com") {
                            // Link the Apple account with the existing Google account
                            try await Auth.auth().currentUser?.link(with: credential)
                            print("Apple account successfully linked with Google account")
                            
                            // Proceed to signed-in state
                            DispatchQueue.main.async {
                                self.authenticationState = .authenticated
                                self.user = Auth.auth().currentUser
                            }
                        } else {
                            // Email is already registered with a different method (e.g., email/password)
                            DispatchQueue.main.async {
                                self.errorMessage = "Your account is already registered with a different method. Please sign in using that method."
                                self.showingErrorAlert = true
                            }
                        }
                    } else {
                        // Proceed with Apple sign-in as a new user
                        let authResult = try await Auth.auth().signIn(with: credential)
                        print("User is signed in with Apple")

                        DispatchQueue.main.async {
                            self.authenticationState = .authenticated
                            self.user = authResult.user
                        }

                        // Check if the user is new or existing
                        let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                        if isNewUser {
                            // Extract user details
                            self.firstName = appleIDCredential.fullName?.givenName ?? ""
                            self.lastName = appleIDCredential.fullName?.familyName ?? ""
                            self.email = authResult.user.email ?? appleIDCredential.email ?? ""
                            self.user_id = authResult.user.uid

                            // Add user to backend
                            self.addUserLambda()
                        } else {
                            // Existing user, fetch user data
                            await self.getUserData()
                        }
                    }
                } catch {
                    print("Error signing in with Apple: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.showingErrorAlert = true
                    }
                }
            }
        }
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let failure) = result {
            // Handle error if the sign-in fails
            errorMessage = failure.localizedDescription
            return
        } else if case .success(let authorization) = result {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: a login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token.")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }

                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
                
                // Perform asynchronous task
                Task {
                    do {
                        let authResult = try await Auth.auth().signIn(with: credential)
                        let firebaseUser = authResult.user
                        let email = firebaseUser.email ?? appleIDCredential.email ?? ""
                        print("User signed in with email: \(email)")
                        
                        // Check if email is already in use with a different sign-in method (e.g., Google)
                        let signInMethods = try await Auth.auth().fetchSignInMethods(forEmail: email)
                        print("Sign-in methods for \(email): \(signInMethods)")

                        if !signInMethods.isEmpty {
                            // If email is already linked with Google, allow linking with Apple
                            if signInMethods.contains("google.com") {
                                // Link the Apple account with the existing Google account
                                try await Auth.auth().currentUser?.link(with: credential)
                                print("Apple account successfully linked with Google account")
                                
                                // Proceed to authenticated state
                                DispatchQueue.main.async {
                                    self.authenticationState = .authenticated
                                    self.user = Auth.auth().currentUser
                                }
                            } else {
                                // Email is already registered with a different method (e.g., email/password)
                                DispatchQueue.main.async {
                                    self.errorMessage = "Your account is already registered with a different method. Please sign in using that method."
                                    self.showingErrorAlert = true
                                }
                            }
                        } else {
                            // Proceed with Apple sign-in as a new user
                            print("User is signed in with Apple")

                            // Check if the user is new or existing
                            let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                            if isNewUser {
                                // Extract user details
                                self.firstName = appleIDCredential.fullName?.givenName ?? ""
                                self.lastName = appleIDCredential.fullName?.familyName ?? ""
                                self.email = authResult.user.email ?? appleIDCredential.email ?? ""
                                self.user_id = authResult.user.uid

                                // Add user to backend
                                self.addUserLambda()

                                // Proceed to authenticated state
                                DispatchQueue.main.async {
                                    self.authenticationState = .authenticated
                                    self.user = authResult.user
                                }
                            } else {
                                // Existing user, fetch user data
                                await self.getUserData()

                                // Proceed to authenticated state
                                DispatchQueue.main.async {
                                    self.authenticationState = .authenticated
                                    self.user = authResult.user
                                }
                            }
                        }
                    } catch {
                        // Handle error during Firebase authentication
                        print("Error signing in with Apple: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.errorMessage = error.localizedDescription
                            self.showingErrorAlert = true
                        }
                    }
                }
            }
        }
    }

    
    
    func updateDisplayName(for user: User, with appleIDCredential: ASAuthorizationAppleIDCredential, force: Bool = false) async {
        if let currentDisplayName = Auth.auth().currentUser?.displayName, !currentDisplayName.isEmpty, !force {
            // current user display name is non-empty, don't overwrite it
            return
        }
        
        let changeRequest = user.createProfileChangeRequest()
        
        // Construct the display name from the fullName property
        if let fullName = appleIDCredential.fullName {
            let givenName = fullName.givenName ?? ""
            let familyName = fullName.familyName ?? ""
            changeRequest.displayName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            // If fullName is nil, you might want to use a default or leave it empty
            changeRequest.displayName = ""
        }
        
        do {
            try await changeRequest.commitChanges()
            self.displayName = Auth.auth().currentUser?.displayName ?? ""
        } catch {
            print("Unable to update the user's display name: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

}

