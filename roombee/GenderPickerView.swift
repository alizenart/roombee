//
//  GenderPickerView.swift
//  roombee
//
//  Created by Adwait Ganguly on 4/17/24.
//

import Foundation
import SwiftUI

struct GenderPickerView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel

    var body: some View {
        Picker("Gender", selection: $viewModel.gender) {
            ForEach(viewModel.genderOptions, id: \.self) { gender in
                Text(gender)
                    .foregroundColor(viewModel.backgroundColor)  // Custom text color
                    .font(.title3)             // Custom font style
                    .tag(gender).bold()
            }
        }
        .pickerStyle(MenuPickerStyle())
        .accentColor(viewModel.backgroundColor)
        .font(.title3)
        .padding()
    }
}

struct GenderPickerView_Previews: PreviewProvider {
    static var previews: some View {
        GenderPickerView().environmentObject(AuthenticationViewModel())
    }
}
