import SwiftUI
import Combine

struct SignupView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var shouldNavigate = false
    
    var body: some View {
        ZStack {
            viewModel.backgroundColor.ignoresSafeArea()
            VStack {
                headerText
                form
                continueButton
                NavigationLink(destination: ContinueSignUp(), isActive: $shouldNavigate) { EmptyView() }
            }
            .padding()
            .background(Rectangle()
                .foregroundColor(Color(red: 230/255, green: 217/255, blue: 197/255))
                .cornerRadius(15)
                .shadow(radius: 15))
            .padding()
        }
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
                .modifier(TextFieldStyle())
                .textContentType(.username)
            
            FormLabelStyle(text: "Password")
            SecureField("", text: $viewModel.password)
                .modifier(TextFieldStyle())
                .textContentType(.oneTimeCode)
            
            FormLabelStyle(text: "Confirm Password")
            SecureField("", text: $viewModel.confirmPassword)
                .modifier(TextFieldStyle())
                .textContentType(.oneTimeCode)
        }
    }
    
    var continueButton: some View {
        Button(action: {
            if viewModel.isValid {
                shouldNavigate = true
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

