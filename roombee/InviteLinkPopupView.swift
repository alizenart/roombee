//
//  InviteLinkPopupView.swift
//  roombee
//
//  Created by Adwait Ganguly on 6/2/24.
//

import Foundation
import SwiftUI

struct InviteLinkPopupView: View {
    let inviteLink: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("Invite Link")
                .font(.headline)
                .padding()
            Text(inviteLink)
                .padding()
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = inviteLink
                    }) {
                        Text("Copy Link")
                        Image(systemName: "doc.on.doc")
                    }
                }
            Button(action: {
                UIPasteboard.general.string = inviteLink
                isPresented = false
            }) {
                Text("Copy and Close")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 20)
        .overlay(
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .padding()
            },
            alignment: .topTrailing
        )
        .padding()
    }
}
