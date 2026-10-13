//
//  PageHeader.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/13/26.
//

import SwiftUI

// "<   Title" header used by pushed screens (sign up steps, Job Posting, job applicants)
struct PageHeader: View {
    
    let title: String
    var titleSize: CGFloat = 20
    var titleColor: Color = .black
    var onBack: (() -> Void)? = nil         // nil hides the back chevron
    
    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: titleSize, weight: .medium))
                .foregroundStyle(titleColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 56)
            
            if let onBack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 26, weight: .regular))
                            .foregroundStyle(titleColor)
                            .frame(width: 44, height: 44, alignment: .leading)
                    }
                    .accessibilityLabel("Back")
                    
                    Spacer()
                }
                .padding(.leading, 39)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
    }
}

// Full-width rounded button: navy fill (Continue, Post) or white fill (Send, Sign Out)
struct SiriusButton: View {
    
    let title: String
    var isFilled: Bool = true
    var width: CGFloat = 280
    var height: CGFloat = 38
    var fontSize: CGFloat = 15
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize))
                .foregroundStyle(isFilled ? Color.white : Color.black)
                .frame(width: width, height: height)
                .background(isFilled ? Color.siriusNavy : Color.white)
                .cornerRadius(10)
        }
    }
}

// Small red message under a form (validation errors)
struct FormErrorText: View {
    
    let message: String?
    
    var body: some View {
        if let message {
            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.siriusDanger)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.85))
                .cornerRadius(6)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PageHeader(title: "Personal Information", onBack: {})
        FormErrorText(message: "Please enter your first name.")
        SiriusButton(title: "Continue") {}
        SiriusButton(title: "Send", isFilled: false) {}
    }
    .appBg()
}
