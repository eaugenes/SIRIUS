//
//  SiriusColor.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/6/26.
//

import SwiftUI
import UIKit

extension Color {
    // Colour that switches between a light and a dark value with the system appearance
    init(light: Color, dark: Color) {
        self.init(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
    
    static func rgb(_ r: Double, _ g: Double, _ b: Double) -> Color {
        Color(red: r / 255, green: g / 255, blue: b / 255)
    }
    
    // Card / sheet / field surface: white in light mode, deep blue-grey in dark mode
    static let siriusSurface = Color(light: .white, dark: .rgb(18, 34, 46))
    // Body text on a surface: black in light mode, near-white in dark mode
    static let siriusText = Color(light: .black, dark: .rgb(236, 244, 250))
    
    // Primary dark blue (buttons, bottom bar, chips)
    static let siriusNavy = Color(red: 0/255, green: 61/255, blue: 92/255)
    
    // Panel blue already used by the applicant screens
    static let siriusPanel = Color(red: 3/255, green: 82/255, blue: 123/255)
    
    // Light sky blue (middle of the screen gradient)
    static let siriusSky = Color(light: Color(red: 216/255, green: 242/255, blue: 255/255), dark: .rgb(12, 74, 108))
    
    // Selected tab pil
    static let siriusHover = Color(red: 232/255, green: 240/255, blue: 255/255)
    
    // Text field border
    static let siriusBorder = Color(red: 159/255, green: 159/255, blue: 159/255)
    
    // Secondary / placeholder text
    static let siriusTextSecondary = Color(light: Color(red: 74/255, green: 74/255, blue: 74/255), dark: .rgb(176, 190, 202))
    
    // Bright green (Average Match card)
    static let siriusMatchGreen = Color(red: 139/255, green: 255/255, blue: 149/255)
    
    // Match bar green (applicant card)
    static let siriusMatchBar = Color(red: 20/255, green: 162/255, blue: 27/255)
    
    // Dark red (remove applicant button)
    static let siriusDanger = Color(red: 119/255, green: 0/255, blue: 0/255)
    
    // Light gray (stepper buttons, selected work setup)
    static let siriusFill = Color(light: Color(red: 240/255, green: 240/255, blue: 240/255), dark: .rgb(40, 58, 72))
    
    // Figma "Final" page tokens
    static let siriusInk = Color(light: Color(red: 0/255, green: 43/255, blue: 69/255), dark: .rgb(232, 243, 250))            // #002b45 headings + field labels
    static let siriusMuted = Color(light: Color(red: 107/255, green: 120/255, blue: 133/255), dark: .rgb(160, 175, 188))      // #6b7885 sub headings
    static let siriusFieldFill = Color(light: Color(red: 245/255, green: 250/255, blue: 252/255), dark: .rgb(27, 47, 62))  // #f5fafc text field fill
    static let siriusFieldBorder = Color(light: Color(red: 204/255, green: 217/255, blue: 227/255), dark: .rgb(58, 84, 102)) // #ccd9e3 text field border
    static let siriusAction = Color(red: 3/255, green: 82/255, blue: 122/255)        // #03527a panel buttons
    static let siriusLink = Color(red: 100/255, green: 196/255, blue: 245/255)       // #64c4f5 "Sign Up" / "Log In" link
    static let siriusTagline = Color(red: 31/255, green: 51/255, blue: 69/255)       // #1f3345 tagline
    static let siriusCredText = Color(red: 115/255, green: 128/255, blue: 140/255)   // #73808c credentials placeholder
    static let siriusDivider = Color(light: Color(red: 217/255, green: 227/255, blue: 235/255), dark: .rgb(46, 68, 84))    // #d9e3eb
    static let siriusRoleTile = Color(light: Color(red: 229/255, green: 242/255, blue: 250/255), dark: .rgb(30, 54, 70))   // #e5f2fa unselected role icon tile
    static let siriusRoleSub = Color(red: 217/255, green: 237/255, blue: 250/255)    // #d9edfa selected role sub text
    static let siriusMatchOrange = Color(red: 243/255, green: 121/255, blue: 0/255)  // #f37900
    static let siriusMatchOrangeFill = Color(red: 239/255, green: 173/255, blue: 68/255).opacity(0.54)
    static let siriusMatchGreenText = Color(red: 0/255, green: 126/255, blue: 6/255) // #007e06
    static let siriusBarAmber = Color(red: 245/255, green: 166/255, blue: 36/255)    // #f5a624 applicant match bar (low)
    static let siriusBarTrack = Color(light: Color(red: 219/255, green: 229/255, blue: 237/255), dark: .rgb(46, 68, 84))   // #dbe5ed applicant match bar track
}
