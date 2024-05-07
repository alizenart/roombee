//
//  TextFieldStyle.swift
//  roombee
//
//  Created by Adwait Ganguly on 5/6/24.
//

import Foundation
import SwiftUI

struct TextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(width: 250, height: 50)
            .overlay(Rectangle().frame(height: 1).padding(.top, 5), alignment: .bottomLeading)
            .cornerRadius(10)
            .padding(.bottom, 5)
            .autocapitalization(.none)
    }
}
