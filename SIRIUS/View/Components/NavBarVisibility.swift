//
//  NavBarVisibility.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI
import Combine

final class NavBarVisibility: ObservableObject {
    @Published private(set) var hideCount = 0
    
    var isHidden: Bool { hideCount > 0 }
    
    func push() { hideCount += 1 }
    func pop() { hideCount = max(0, hideCount - 1) }
}

private struct NavBarVisibilityKey: EnvironmentKey {
    static let defaultValue: NavBarVisibility? = nil          // nil in previews: hiding does nothing
}

extension EnvironmentValues {
    var navBarVisibility: NavBarVisibility? {
        get { self[NavBarVisibilityKey.self] }
        set { self[NavBarVisibilityKey.self] = newValue }
    }
}

private struct HidesNavBarModifier: ViewModifier {
    let hides: Bool
    
    @Environment(\.navBarVisibility) private var visibility
    @State private var isCounted = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard hides, !isCounted else { return }
                isCounted = true
                visibility?.push()
            }
            .onDisappear {
                guard isCounted else { return }
                isCounted = false
                visibility?.pop()
            }
    }
}

extension View {
    // Hides the bottom navigation bar while this page is on screen
    func hidesSiriusNavBar(_ hides: Bool = true) -> some View {
        modifier(HidesNavBarModifier(hides: hides))
    }
}

enum NavBarMetrics {
    // Space a tab page leaves at its bottom so the floating bar (50 high + 10 padding + 10 gap) does not cover it
    static let clearance: CGFloat = 92
}
