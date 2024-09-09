import SwiftUI

@MainActor
struct ContentView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var navManager: NavManager
    @EnvironmentObject var selectedDate: SelectedDateManager
    @EnvironmentObject var toggleManager: ToggleViewModel
    @EnvironmentObject var eventStore: EventStore
    @EnvironmentObject var todoManager: TodoViewModel
    @EnvironmentObject var agreementManager: RoommateAgreementHandler
    @EnvironmentObject var agreementStore: RoommateAgreementStore

    @EnvironmentObject var onboardGuideManager: OnboardGuideViewModel
    @State private var isTimerDone = false
    

    var body: some View {
        
        switch viewModel.authenticationState {
        case .authenticated:
            HomepageView()
                .environmentObject(eventStore)
                .environmentObject(viewModel)
                .environmentObject(navManager)
                .environmentObject(selectedDate)
                .environmentObject(toggleManager)
                .environmentObject(todoManager)
                .environmentObject(agreementManager)
                .environmentObject(agreementStore)
//            OnboardGuideView(viewModel: onboardGuideManager)

        case .authenticating, .unauthenticated:
            if isTimerDone {
                NavigationView {
                    LoginView()
                        .environmentObject(viewModel)
                        .environmentObject(onboardGuideManager)
                }
            } else {
                splashScreen
            }
        }
    }
    
    var splashScreen: some View {
        ZStack {
            Color(hex: "#381e38").ignoresSafeArea()
            VStack {
                Text("Roombee").font(.largeTitle).bold().foregroundColor(.yellow)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isTimerDone = true
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let scanner = Scanner(string: hex.hasPrefix("#") ? String(hex.dropFirst()) : hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AuthenticationViewModel())
    }
}



