//
//  ScaledFont.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

// Dynamic Type support for the fixed point sizes taken from the Figma design.
// The design size is the size at the default text setting; it grows / shrinks with
// the user's Text Size setting (capped at xxxLarge by AdaptiveRoot so fixed cards still fit).

import SwiftUI
import UIKit

private struct ScaledFontModifier: ViewModifier {
    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight
    
    init(size: CGFloat, weight: Font.Weight) {
        _size = ScaledMetric(wrappedValue: size, relativeTo: .body)
        self.weight = weight
    }
    
    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight))
    }
}

extension View {
    // Same as `.scaledFont(size: weight:)` but follows the Dynamic Type setting
    func scaledFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        modifier(ScaledFontModifier(size: size, weight: weight))
    }
}

extension Font {
    // For places that must stay a `Text` (placeholder prompts): scales with the current text size
    static func scaled(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: UIFontMetrics(forTextStyle: .body).scaledValue(for: size), weight: weight)
    }
}
