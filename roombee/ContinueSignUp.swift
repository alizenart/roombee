import SwiftUI
import Combine

struct ContinueSignUp: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert = false
    @State private var shouldNavigate = false
    
    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel

    
    var body: some View {
        ZStack {
            BackgroundView()
            content
        }
    }

    private var content: some View {
        VStack {
            headerText
            form
            signUpButton
            NavigationLink(destination: destinationView, isActive: $shouldNavigate) { EmptyView() }
        }
        .padding()
        .backgroundForm()
        .padding()
    }

    @ViewBuilder
    private var destinationView: some View {
        if viewModel.skipCreateOrJoin {
            HomepageView()
            .environmentObject(EventStore())
            .environmentObject(viewModel)
            .environmentObject(NavManager())
            .environmentObject(SelectedDateManager())
            .environmentObject(ToggleViewModel())


        } else {
            Onboarding2()
                .environmentObject(onboardGuideManager)
        }
    }

    private var headerText: some View {
        Text("Create Profile")
            .font(.largeTitle)
            .bold()
            .padding()
            .foregroundColor(Color(red: 73/255, green: 73/255, blue: 73/255))
    }

    private var form: some View {
        VStack {
            DatePickerModule()
            GenderPickerView()
            FormLabelStyle(text: "First Name")
            TextField("", text: $viewModel.firstName).modifier(TextFieldStyle())
                .disableAutocorrection(true)
            FormLabelStyle(text: "Last Name")
            TextField("", text: $viewModel.lastName).modifier(TextFieldStyle())
                .disableAutocorrection(true)
        }
    }

    private var signUpButton: some View {
        Button(action: {
            Task {
                if (!viewModel.firstName.isEmpty && !viewModel.lastName.isEmpty
                    && !viewModel.gender.isEmpty) {
                    if await viewModel.signUpWithEmailPassword() {
                        shouldNavigate = true
                    } else {
                        showingAlert = true
                    }
                }
                else{
                    showingAlert = true
                }
            }
        }) {
            buttonContent
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
        .disabled(!viewModel.isValid)
        .frame(width: 250, height: 50)
        .buttonStyle(.borderedProminent)
        .padding()
    }


    private var buttonContent: some View {
        Group {
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
    }

    private var backgroundForm: some View {
        Rectangle()
            .foregroundColor(Color(red: 230/255, green: 217/255, blue: 197/255))
            .cornerRadius(15)
            .shadow(radius: 15)
    }
}

struct BackgroundView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    var body: some View {
        viewModel.backgroundColor
            .ignoresSafeArea()
    }
}

struct ContinueSignUpPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            ContinueSignUp()
                .environmentObject(AuthenticationViewModel())
            ContinueSignUp()
                .preferredColorScheme(.dark)
                .environmentObject(AuthenticationViewModel())
        }
    }
}

