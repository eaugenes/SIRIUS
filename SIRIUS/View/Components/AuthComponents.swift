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

// Logo + "SIRIUS" + tagline, positioned like the Final frames (logo top 104, panel top 392)
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

// White rounded panel (radius 24, shadow 0/8/24) with the heading block on top
struct AuthPanel<Content: View>: View {
    
    let heading: String
    let subheading: String
    @ViewBuilder var content: () -> Content
    
    var body: some View {
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
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 20)
        .fluidFrame(width: 365, alignment: .leading)
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color(red: 0, green: 26/255, blue: 51/255).opacity(0.25), radius: 12, x: 0, y: 8)
    }
}

// Labeled field used inside AuthPanel (325 wide, 35 high, radius 14)
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
                .padding(.leading, 23)
            
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
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 5) {
            Text(prompt)
                .scaledFont(size: 15)
                .foregroundStyle(Color.white)
            Button(action: action) {
                Text(link)
                    .scaledFont(size: 15, weight: .medium)
                    .underline()
                    .foregroundStyle(Color.siriusLink)
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

// Applicant "Finish Sign Up" credentials block: two 52pt rows (password, confirm) in one rounded container
struct CredentialsGroup: View {
    
    @Binding var password: String
    @Binding var confirmPassword: String
    
    var body: some View {
        VStack(spacing: 0) {
            row { SecureField("", text: $password, prompt: prompt("Enter your password")) }
            divider
            row { SecureField("", text: $confirmPassword, prompt: prompt("Re-enter your password")) }
        }
        .frame(maxWidth: .infinity)
        .background(Color.siriusFieldFill)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.siriusFieldBorder, lineWidth: 1))
    }
    
    private func row<F: View>(@ViewBuilder _ field: () -> F) -> some View {
        field()
            .scaledFont(size: 16)
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.siriusDivider)
            .frame(height: 1)
            .padding(.leading, 16)
    }
    
    private func prompt(_ text: String) -> Text {
        Text(text).font(.scaled(16)).foregroundColor(Color.siriusCredText)
    }
}

// White panel used by the sign up steps (Figma "Form panel": x19, top 82, radius 24).
// Title row (back circle + centered title) on top, caller content below.
struct SignUpPanel<Content: View>: View {
    
    let title: String
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
        .padding(.bottom, 20)
        .fluidFrame(width: 365)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.siriusSurface)
                .shadow(color: Color(red: 0, green: 26/255, blue: 51/255).opacity(0.25), radius: 12, x: 0, y: 8)
        )
        .padding(.top, 82)
        .padding(.bottom, 40)
    }
}

// Multi-colour Google "G" drawn in SwiftUI (no image asset needed)
struct GoogleLogo: View {
    
    var size: CGFloat = 22
    
    private let red = Color(red: 234/255, green: 67/255, blue: 53/255)
    private let yellow = Color(red: 251/255, green: 188/255, blue: 5/255)
    private let green = Color(red: 52/255, green: 168/255, blue: 83/255)
    private let blue = Color(red: 66/255, green: 133/255, blue: 244/255)
    
    var body: some View {
        let line = size * 0.2
        let box = size - line
        
        ZStack {
            // trim starts at 3 o'clock and runs clockwise: 0.25 = bottom, 0.5 = left, 0.75 = top
            arc(from: 0.0, to: 0.12, color: blue, line: line)        // right, below the bar
            arc(from: 0.12, to: 0.37, color: green, line: line)      // bottom
            arc(from: 0.37, to: 0.55, color: yellow, line: line)     // lower left
            arc(from: 0.55, to: 0.80, color: red, line: line)        // upper left + top
            arc(from: 0.80, to: 0.875, color: red, line: line)       // top right tip
            // horizontal bar of the G
            Rectangle()
                .fill(blue)
                .frame(width: box / 2 + line / 2, height: line)
                .offset(x: box / 4 - line / 4 + line / 2, y: 0)
        }
        .frame(width: box, height: box)
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
    
    private func arc(from: Double, to: Double, color: Color, line: CGFloat) -> some View {
        Circle()
            .trim(from: from, to: to)
            .stroke(color, style: StrokeStyle(lineWidth: line, lineCap: .butt))
    }
}
