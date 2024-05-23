//
//  LabelStyle.swift
//  roombee
//
//  Created by Adwait Ganguly on 5/6/24.
//

import Foundation
import SwiftUI

struct LabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, -120)
            .padding(.bottom, -100)
            .foregroundColor(Color.gray)
            .font(.system(size: 15))
    }
}
