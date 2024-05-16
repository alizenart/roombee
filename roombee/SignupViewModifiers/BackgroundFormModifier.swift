//
//  BackgroundFormModifier.swift
//  roombee
//
//  Created by Adwait Ganguly on 5/6/24.
//

import Foundation
import SwiftUI

struct BackgroundFormModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Rectangle()
                .foregroundColor(Color(red: 230/255, green: 217/255, blue: 197/255))
                .cornerRadius(15)
                .shadow(radius: 15))
    }
}

extension View {
    func backgroundForm() -> some View {
        self.modifier(BackgroundFormModifier())
    }
}

