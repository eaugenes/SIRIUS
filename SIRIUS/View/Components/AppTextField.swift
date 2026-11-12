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
    var isSecure: Bool = false
    var isMultiline: Bool = false
    
    var titleColor: Color = .siriusInk
    var borderColor: Color = .siriusFieldBorder
    var multilineHeight: CGFloat = 100
    var prefix: String? = nil                       // e.g. "₱" shown before the typed text
    var keyboardType: UIKeyboardType = .default     // .numberPad for numbers, .emailAddress for emails
    var widthField: CGFloat? = 300                  // nil = as wide as the space it is given
    @State private var isRevealed = false
    
    // Figma "Final": Light 14 placeholder in the secondary text color
    private var promptText: Text {
        Text(placeholder)
            .font(.scaled(14, .light))
            .foregroundColor(Color.siriusTextSecondary)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .scaledFont(size: 13)
                .fontWeight(.medium)
                .foregroundStyle(titleColor)
                .padding(.leading, 11)
            
            if isMultiline {
                ZStack(alignment: .topLeading){
                    TextEditor(text: $text)
                        .accessibilityLabel(title)
                        .scrollContentBackground(.hidden)
                        .scaledFont(size: 14, weight: .light)
                        .foregroundStyle(Color.siriusText)
                        .padding(6)
                    if text.isEmpty {
                        Text(placeholder)
                            .scaledFont(size: 14, weight: .light)
                            .foregroundStyle(Color.siriusTextSecondary)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 14)
                            .allowsHitTesting(false)        // let taps reach the TextEditor underneath
                    }
                }
                .frame(height: multilineHeight)
                .fieldWidth(widthField)
                .background(Color.siriusFieldFill)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(borderColor, lineWidth: 1)
                )
            } else if isSecure {           // For Password
                HStack(spacing: 8) {
                    Group {
                        if isRevealed {
                            TextField("", text: $text, prompt: promptText)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        } else {
                            SecureField("", text: $text, prompt: promptText)
                        }
                    }
                    .accessibilityLabel(title)
                    .scaledFont(size: 14, weight: .light)
                    
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash" : "eye")
                            .scaledFont(size: 10, weight: .medium)
                            .foregroundStyle(Color.gray)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
                }
                .padding(10)
                .fieldWidth(widthField)
                .frame(minHeight: 35)
                .background(Color.siriusFieldFill)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(borderColor, lineWidth: 1)
                )
            } else {                // For Any Type of TextField
                HStack(spacing: 4) {
                    if let prefix {
                        Text(prefix)
                            .scaledFont(size: 14, weight: .medium)
                            .foregroundStyle(Color.siriusInk)
                    }
                    TextField("", text: $text, prompt: promptText)
                        .accessibilityLabel(title)
                        .scaledFont(size: 14, weight: .light)
                        .keyboardType(keyboardType)
                }
                    .padding(10)
                    .fieldWidth(widthField)
                    .frame(minHeight: 35)
                    .background(Color.siriusFieldFill)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(borderColor, lineWidth: 1)
                    )
            }
            
        }
    }
}

private extension View {
    // A fixed width, or the full width available when `width` is nil
    @ViewBuilder
    func fieldWidth(_ width: CGFloat?) -> some View {
        if let width {
            self.frame(width: width)
        } else {
            self.frame(maxWidth: .infinity)
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
