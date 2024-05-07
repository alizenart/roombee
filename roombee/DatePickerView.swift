//
//  DatePickerView.swift
//  roombee
//
//  Created by Adwait Ganguly on 4/17/24.
//

import SwiftUI

struct DatePickerModule: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            DatePicker("Birthday", selection: $viewModel.birthDate,
                       in: ...Date(),
                       displayedComponents: .date
            ).font(.title3).bold().foregroundColor(viewModel.backgroundColor)
            .padding(.horizontal, 25)  // Reduced horizontal padding
        }
        .padding()
    }
}

struct DatePickerModule_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerModule().environmentObject(AuthenticationViewModel())
    }
}
