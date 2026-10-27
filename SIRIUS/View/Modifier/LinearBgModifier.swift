//
//  LinearBgModifier.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct LinearBgModifier: ViewModifier {
    
    // Figma "Final": #003d5c -> #d8f2ff -> #003d5c (stops 3.365% / 57.692% / 100%)
    let topBotBlue = Color.siriusNavy
    let centerWhite = Color.siriusSky
    
    func body(content: Content) -> some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: topBotBlue, location: 0.03365),
                    .init(color: centerWhite, location: 0.57692),
                    .init(color: topBotBlue, location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .all)
            
            content
        }
    }
}

extension View {
    func appBg() -> some View {
        self.modifier(LinearBgModifier())
    }
}
