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
        VStack {
            HStack {
                Text("Gender")
                    .font(.title3)
                    .bold()
                    .foregroundColor(viewModel.backgroundColor)
                
                Picker("Gender", selection: $viewModel.gender) {
                    ForEach(viewModel.genderOptions, id: \.self) { gender in
                        Text(gender)
                            .tag(gender)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(viewModel.backgroundColor)
                .font(.title3)
            }
            .padding(.horizontal, 25)  // Adjust padding as needed
        }
        .padding()
    }
}

struct GenderPickerView_Previews: PreviewProvider {
    static var previews: some View {
        GenderPickerView().environmentObject(AuthenticationViewModel())
    }
}
