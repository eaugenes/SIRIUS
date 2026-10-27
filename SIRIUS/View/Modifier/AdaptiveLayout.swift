//
//  AdaptiveLayout.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

extension View {
    // The Figma frames are 402 wide. `fluidFrame` keeps that size on a 402 iPhone but lets the view
    // shrink on narrower phones (iPhone SE / mini) instead of overflowing the screen.
    func fluidFrame(width: CGFloat, height: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        self
            .frame(maxWidth: width, alignment: alignment)
            .frame(minHeight: height, alignment: alignment)
    }
    
    func fluidFrame(width: CGFloat, minHeight: CGFloat, alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: width, minHeight: minHeight, alignment: alignment)
    }
}

// iPad / large windows: keep the phone layout in a centred column instead of stretching it.
struct AdaptiveRoot<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        if sizeClass == .regular {
            ZStack {
                LinearGradient(
                    colors: [Color.siriusNavy, Color.siriusSky, Color.siriusNavy],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
                content()
                    .frame(maxWidth: 480)
                    .clipped()
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            }
        } else {
            content()
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
}
