//
//  ScaledFont.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

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
    func scaledFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        modifier(ScaledFontModifier(size: size, weight: weight))
    }
}

extension Font {
    static func scaled(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: UIFontMetrics(forTextStyle: .body).scaledValue(for: size), weight: weight)
    }
}
