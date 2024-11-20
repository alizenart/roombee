import SwiftUI

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
                    Alert(title: Text("Incorrect Email or Password"), dismissButton: .default(Text("OK")))
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
    
    var googleSignIn: some View {
        HStack {
            Button("Sign in with Google") {
                Task {
                    let success = await viewModel.signInWithGoogle()
                    if success {
                        print("Sign-in successful")
                    } else {
                        print("Sign-in failed")
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(alignment: .leading) {
                Image("Google")
                    .frame(width: 30, alignment: .center)
            }
        }
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

