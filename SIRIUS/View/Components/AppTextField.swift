//
//  AppTextField.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI
import UIKit

struct AppTextField: View {
    
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false          // for SecureField
    var isMultiline: Bool = false       // for multi-line text (e.g. Description/s)
    
    // Optional styling (defaults keep every existing call site unchanged)
    var titleColor: Color = .black                      // white on dark panels (e.g. Schedule Interview)
    var borderColor: Color = .gray                      // Job Posting uses Color.siriusPanel
    var multilineHeight: CGFloat = 100                  // About Company / Job Description / Message
    var keyboardType: UIKeyboardType = .default         // .numberPad for numbers, .emailAddress for emails
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 13))
                .fontWeight(.medium)
                .foregroundStyle(titleColor)
                .padding(2)
            
            if isMultiline {
                ZStack(alignment: .topLeading){
                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.black)
                        .padding(6)
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.gray)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 14)
                            .allowsHitTesting(false)        // let taps reach the TextEditor underneath
                    }
                }
                .frame(width: 300, height: multilineHeight)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(borderColor, lineWidth: 1)
                )
            } else if isSecure {           // For Password
                SecureField(placeholder, text: $text)
                    .font(.system(size: 12))
                    .padding(10)
                    .frame(width: 300, height: 35)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(borderColor, lineWidth: 1)
                    )
            } else {                // For Any Type of TextField
                TextField(placeholder, text: $text)
                    .font(.system(size: 12))
                    .keyboardType(keyboardType)
                    .padding(10)
                    .frame(width: 300, height: 35)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(borderColor, lineWidth: 1)
                    )
            }
            
        }
    }
}

#Preview {
    VStack {
        AppTextField(title: "Username", placeholder: "Enter your username", text: .constant(""))
        AppTextField(title: "About Company", placeholder: "Enter company about", text: .constant(""), isMultiline: true)
    }
    .appBg()
}
