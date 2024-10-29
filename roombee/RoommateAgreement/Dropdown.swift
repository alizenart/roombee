//
//  Dropdown.swift
//  roombee
//
//  Created by Ziye Wang on 7/17/24.
//

import SwiftUI

struct DropdownView: View {
    let title: String
    let prompt: String
    let options: [String]
    
    @State private var isExpanded = false
    
    @Binding var selection: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.gray)
                .opacity(0.8)
            
            VStack{
                HStack{
                    Text(selection.isEmpty ? prompt : selection.joined(separator: ", "))

                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                }
                .frame(height: 40)
                .padding(.horizontal)
                .contentShape(Rectangle()) // trying to fix click exmpty space

                .onTapGesture{
                    withAnimation(.snappy) {isExpanded.toggle()}
                }
                
                if isExpanded {
                    VStack{
                        ForEach(options, id: \.self) {option in
                            HStack {
                                Text(option)
                                    .foregroundStyle(selection.contains(option) ? Color.primary : .gray)
                                Spacer()
                                
                                if selection.contains(option) {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                }
                            }
                            .frame(height: 40)
                            .background(.white)
                            .padding(.horizontal)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    if selection.contains(option) {
                                        selection.removeAll {$0 == option}
                                    }
                                    else {
                                        selection.append(option)

                                    }
//                                    isExpanded.toggle()
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 4)
//            .frame(width: 200)

        }
    }
}

struct SingleSelectionDropdownView: View {
    let title: String
    let prompt: String
    let options: [String]
    
    @State private var isExpanded = false
    @Binding var selection: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.gray)
                .opacity(0.8)
            
            VStack {
                HStack {
                    Text(selection.isEmpty ? prompt : selection)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                }
                .frame(height: 40)
                .padding(.horizontal)
                .contentShape(Rectangle()) // trying to fix click exmpty space

                .onTapGesture {
                    withAnimation(.snappy) {
                        isExpanded.toggle()
                    }
                }
                
                if isExpanded {
                    VStack {
                        ForEach(options, id: \.self) { option in
                            HStack {
                                Text(option)
                                    .foregroundStyle(selection == option ? Color.primary : .gray)
                                Spacer()
                                
                                if selection == option {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                }
                            }
                            .frame(height: 40)
                            .background(.white)
                            .padding(.horizontal)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    selection = option
                                    isExpanded.toggle() // Collapse after selection
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 4)
        }
    }
}



#Preview {
    DropdownView(title: "Make", prompt: "Select", options: [
    "Lambda",
    "Farrari",
    "Aston Martin"],
             selection: .constant([]))
}
