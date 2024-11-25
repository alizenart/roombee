import SwiftUI

import AuthenticationServices


struct LoginView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingErrorAlert = false
    
    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel

    
    var body: some View {
        NavigationView {
            ZStack {
                viewModel.backgroundColor
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                VStack(spacing: 25){
                    Text("Login")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .foregroundColor(Color(red: 73/255, green: 73/255, blue: 73/255))
                    
                    loginForm
                    
                    Button(action: signInWithEmailPassword) {
                        loginButtonContent
                        
                    }
                    .disabled(!viewModel.isValid)
                    .buttonStyle(.borderedProminent)
                    .frame(width: 250, height: 50)
                    
                    signUpLink
                    
                    googleSignIn
                    
                    appleSignIn
                    
                    NavigationLink(destination: SignupView().environmentObject(onboardGuideManager), isActive: $viewModel.showSignUp) {
                        EmptyView()
                    }
                }
                .padding()
                .background(Rectangle()
                    .foregroundColor(Color(red: 230/255, green: 217/255, blue: 197/255))
                    .cornerRadius(15)
                    .shadow(radius: 15))
                .padding()
                .navigationBarBackButtonHidden(true)
                .alert(isPresented: $showingErrorAlert){
                    Alert(title: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func signInWithEmailPassword() {
        Task {
            if await viewModel.signInWithEmailPassword() == true {
                dismiss()
            }
            else{
                showingErrorAlert = true
            }
        }
    }
    
    var loginForm: some View {
        Group {
            LabelText(text: "Email")
            TextField("", text: $viewModel.email)
                .modifier(TextFieldModifier())
            
            LabelText(text: "Password")
            SecureField("", text: $viewModel.password)
                .modifier(TextFieldModifier())
        }
    }
    
    var loginButtonContent: some View {
        Group {
            if viewModel.authenticationState != .authenticating {
                Text("Login")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    var signUpLink: some View {
        HStack {
            Text("Don't have an account yet?").font(.system(size: 15))
            Button("Sign Up", action: viewModel.switchFlow)
        }
        .padding([.top, .bottom], 25)
    }
    
    var appleSignIn: some View {
        SignInWithAppleButton(.signIn, onRequest: { request in
            let nonce = viewModel.randomNonceString()
            viewModel.currentNonce = nonce
            request.requestedScopes = [.fullName, .email]
            request.nonce = viewModel.sha256(nonce)
        }, onCompletion: { result in
            switch result {
            case .success(let authResults):
                viewModel.handleSignInWithApple(authResults)
            case .failure(let error):
                print("Authorization failed: \(error.localizedDescription)")
                viewModel.errorMessage = error.localizedDescription
                viewModel.showingErrorAlert = true
            }
        })
        .signInWithAppleButtonStyle(.black)
        .frame(height: 45)
        .padding()
    }

    
    var googleSignIn: some View {
        Button(action: {
            Task {
                let success = await viewModel.signInWithGoogle()
                if success {
                    print("Sign-in successful")
                } else {
                    print("Sign-in failed")
                }
            }
        }) {
            HStack(spacing: 10) {
                // Google Icon
                Image("Google") // Replace with the actual name of your Google logo asset
                    .resizable()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                
                // Text
                Text("Sign in with Google")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .padding(.horizontal, 12)
            .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255)) // Light gray background
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.clear, lineWidth: 1)
            )
        }
        .frame(minWidth: 200, maxWidth: 400)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }

}

struct LabelText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .modifier(LabelStyleModifier())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .environmentObject(AuthenticationViewModel())
            LoginView()
                .preferredColorScheme(.dark)
                .environmentObject(AuthenticationViewModel())
        }
    }
}

