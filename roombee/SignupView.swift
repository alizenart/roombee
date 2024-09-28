import SwiftUI
import Combine

struct SignupView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var shouldNavigate = false
    @State private var showingPasswordAlert = false
    @State private var showingErrorAlert = false
    
    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel

    
    var body: some View {
        ZStack {
            viewModel.backgroundColor
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            VStack {
                headerText
                form
                continueButton
                NavigationLink(destination: ContinueSignUp().environmentObject(onboardGuideManager), isActive: $shouldNavigate) { EmptyView() }
            }
            .padding()
            .background(Rectangle()
                .foregroundColor(Color(red: 230/255, green: 217/255, blue: 197/255))
                .cornerRadius(15)
                .shadow(radius: 15))
            .padding()
        }
        .alert(isPresented: $showingErrorAlert) {
            Alert(title: Text("Oops!"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var headerText: some View {
        Text("Create Profile")
            .font(.largeTitle)
            .bold()
            .padding()
            .foregroundColor(Color(red: 73/255, green: 73/255, blue: 73/255))
    }
    
    var form: some View {
        Group {
            FormLabelStyle(text: "Email")
            TextField("", text: $viewModel.email)
                .modifier(TextFieldModifier())
                .textContentType(.username)
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)
            FormLabelStyle(text: "Password")
            SecureInputField(text: $viewModel.password)
                    .padding()
            PasswordGuidelinesView(password: $viewModel.password)
                .padding(.bottom, 10)
            FormLabelStyle(text: "Confirm Password")
            SecureInputField(text: $viewModel.confirmPassword)
                .padding()
        }
    }
    
    var continueButton: some View {
        Button(action: {
            Task {
                print("Continue button pressed. Validating email, password, and confirmation.")
                if await viewModel.isEmailAlreadyInUse(email: viewModel.email) {
                    // Email is already in use, show an error message
                    print("Email is in use.")
                    viewModel.errorMessage = "The email address is already in use."
                    showingErrorAlert = true
                } else if !viewModel.validatePassword(viewModel.password) {
                    // Password does not meet the requirements
                    viewModel.errorMessage = "Does not meet password requirements"
                    showingErrorAlert = true
                } else if viewModel.password != viewModel.confirmPassword {
                    // Passwords do not match
                    viewModel.errorMessage = "Passwords don't match"
                    showingErrorAlert = true
                } else {
                    // Passwords are valid and match, proceed with navigation
                    shouldNavigate = true
                }
            }
        }) {
            if viewModel.authenticationState != .authenticating {
                Text("Continue")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
        }
        .disabled(!viewModel.isValid)
        .frame(width: 250, height: 50)
        .buttonStyle(.borderedProminent)
        .padding()
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignupView()
            SignupView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(AuthenticationViewModel())
    }
}

struct PasswordGuidelinesView: View {
    @Binding var password: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Password must include:")
                .font(.headline)
                .padding(.bottom, 5)

            PasswordRequirementView(isMet: password.count >= 8, text: "At least 8 characters")
            PasswordRequirementView(isMet: containsUppercase, text: "At least one uppercase letter (A-Z)")
            PasswordRequirementView(isMet: containsLowercase, text: "At least one lowercase letter (a-z)")
            PasswordRequirementView(isMet: containsDigit, text: "At least one digit (0-9)")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
    }

    // Password validation checks
    private var containsUppercase: Bool {
        password.rangeOfCharacter(from: .uppercaseLetters) != nil
    }

    private var containsLowercase: Bool {
        password.rangeOfCharacter(from: .lowercaseLetters) != nil
    }

    private var containsDigit: Bool {
        password.rangeOfCharacter(from: .decimalDigits) != nil
    }

}
struct PasswordRequirementView: View {
    var isMet: Bool
    var text: String

    var body: some View {
        HStack(spacing: 3) {  // Very tight spacing between the icon and text
            Image(systemName: isMet ? "checkmark" : "circle")
                .foregroundColor(isMet ? Color.green.opacity(0.5) : Color.red.opacity(0.3))
                .imageScale(.small)  // Smaller icon size
            Text(text)
                .foregroundColor(isMet ? Color.gray.opacity(0.7) : Color.primary.opacity(0.6))
                .font(.footnote)  // Smaller text size
        }
        .padding(.vertical, 0.5)  // Minimal vertical padding
    }
}

struct SecureInputField: View {
    @Binding var text: String
    @State private var isSecure: Bool = true

    var body: some View {
        HStack {
            if isSecure {
                SecureField("", text: $text)
            } else {
                TextField("", text: $text)
            }
            Button(action: {
                isSecure.toggle()
                
            }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(Color.gray.opacity(0.7))
            }
        }
        .modifier(TextFieldStyle())
        .padding(.trailing, 10)
    }
}


