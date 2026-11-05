//
//  AuthComponents.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

// Shared pieces of the Figma "Final" authentication screens
// (Log In, Choose Role, Finish Sign Up): brand header, white panel,
// panel text field and the panel action button.

import SwiftUI

struct AuthBrandHeader: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("sirius-logo")
                .resizable()
                .scaledToFill()
                .frame(width: 158, height: 148)
                .clipped()
                .padding(.top, 104)
            
            Text("SIRIUS")
                .scaledFont(size: 64, weight: .medium)
                .tracking(12.8)
                .padding(.leading, 12.8)            // balances the trailing tracking space
                .foregroundStyle(Color.siriusText)
                .frame(height: 76)
                .padding(.top, 15)
            
            Text("In a sky full of opportunities, let the right one find you.")
                .scaledFont(size: 12)
                .foregroundStyle(Color.siriusTagline)
                .padding(.top, 8)
                .padding(.bottom, 26)
        }
    }
}

struct AuthPanel<Content: View>: View {
    let heading: String
    let subheading: String
    var fillsScreenBottom: Bool = false
    @ViewBuilder var content: () -> Content
    
    private var inner: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(heading)
                    .scaledFont(size: 22, weight: .bold)
                    .foregroundStyle(Color.siriusInk)
                Text(subheading)
                    .scaledFont(size: 13)
                    .foregroundStyle(Color.siriusMuted)
            }
            .lineLimit(1)
            
            content()
        }
    }
    
    var body: some View {
        if fillsScreenBottom {
            inner
                .frame(width: 325, alignment: .leading)
                .padding(.top, 28)
                .padding(.bottom, 40)
                .frame(maxWidth: 375, maxHeight: 425, alignment: .top)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.siriusSurface)
                        .shadow(color: Color(red: 0, green: 26/255, blue: 51/255).opacity(0.25), radius: 12, x: 0, y: 8)
                )
        } else {
            inner
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 20)
                .fluidFrame(width: 365, alignment: .leading)
                .background(Color.siriusSurface)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color(red: 0, green: 26/255, blue: 51/255).opacity(0.25), radius: 12, x: 0, y: 8)
        }
    }
}


struct AuthField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .scaledFont(size: 13, weight: .medium)
                .foregroundStyle(Color.siriusInk)
                .padding(.leading, 11)
            
            Group {
                if isSecure {
                    SecureField("", text: $text, prompt: prompt)
                } else {
                    TextField("", text: $text, prompt: prompt)
                }
            }
            .scaledFont(size: 14, weight: .light)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 10)
            .frame(width: 325)
                    .frame(minHeight: 35)
            .background(Color.siriusFieldFill)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.siriusFieldBorder, lineWidth: 1))
        }
    }
    
    private var prompt: Text {
        Text(placeholder)
            .font(.scaled(14, .light))
            .foregroundColor(Color.siriusTextSecondary)
    }
}

// 52 high, radius 16, #03527a panel button ("Continue", "Complete Profile")
struct AuthButton: View {
    
    let title: String
    var fontSize: CGFloat = 17
    var isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .scaledFont(size: fontSize, weight: .semibold)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 52)
                .background(Color.siriusAction)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

// "Don't have an account yet?  Sign Up" footer link
struct AuthFooterLink: View {
    let prompt: String
    let link: String
    var promptColor: Color = .white
    var linkColor: Color = .siriusLink
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 5) {
            Text(prompt)
                .scaledFont(size: 15)
                .foregroundStyle(promptColor)
            Button(action: action) {
                Text(link)
                    .scaledFont(size: 15, weight: .medium)
                    .underline()
                    .foregroundStyle(linkColor)
            }
        }
    }
}

// Back chevron circle (white, 42pt) used on the sign up steps
struct CircleBackButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.backward")
                .scaledFont(size: 20)
                .foregroundStyle(Color.siriusText)
                .frame(width: 42, height: 42)
                .background(Color.siriusSurface)
                .clipShape(Circle())
        }
        .accessibilityLabel("Back")
    }
}

struct SignUpPanel<Content: View>: View {
    
    let title: String
    var fillsScreen: Bool = false
    var bottomGap: CGFloat = 0
    let onBack: () -> Void
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(title)
                    .scaledFont(size: 20, weight: .semibold)
                    .foregroundStyle(Color.siriusText)
                
                HStack {
                    CircleBackButton(action: onBack)
                    Spacer()
                }
                .padding(.leading, 10)
            }
            .frame(height: 42)
            .padding(.top, 10)
            
            content()
        }
        .padding(.bottom, fillsScreen ? 40 : 20)
        .fluidFrame(width: 365)
        .frame(maxHeight: fillsScreen ? CGFloat.infinity : nil)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.siriusSurface)
                .shadow(color: Color(red: 0, green: 26/255, blue: 51/255).opacity(0.25), radius: 12, x: 0, y: 8)
        )
        .padding(.top, 82)
        .padding(.bottom, fillsScreen ? bottomGap : 40)
    }
}
