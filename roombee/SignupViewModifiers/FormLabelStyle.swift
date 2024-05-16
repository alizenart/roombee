//
//  FormLabelStyle.swift
//  roombee
//
//  Created by Adwait Ganguly on 5/6/24.
//

import Foundation
// FormLabel.swift
import SwiftUI

struct FormLabelStyle: View {
    var text: String

    var body: some View {
        Text(text)
            .modifier(LabelStyle())
    }
}
