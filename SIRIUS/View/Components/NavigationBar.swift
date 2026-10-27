//
//  NavigationBar.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/14/26.
//

import SwiftUI

// Anything that can drive the bottom bar: a tab's label (rawValue) and SF Symbol (iconTypes).
// AplNavigationTab and EmpNavigationTab already have both, so conforming them costs nothing.
protocol SiriusNavigationTab: Hashable, CaseIterable, Identifiable where AllCases: RandomAccessCollection {
    var rawValue: String { get }
    var iconTypes: String { get }
}

extension AplNavigationTab: SiriusNavigationTab {}
extension EmpNavigationTab: SiriusNavigationTab {}

// MARK: Reusable Nav Bar
// Dark-blue capsule bar with a light pill behind the selected tab.
// Works for any tab enum conforming to SiriusNavigationTab.
struct NavigationBar<Tab: SiriusNavigationTab>: View {
    @Binding var selectedTab: Tab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases) { tab in
                let isActive = selectedTab == tab
                
                Button {
                    withAnimation(.spring(duration: 0.3, bounce: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 0) {
                        Image(systemName: tab.iconTypes)
                            .scaledFont(size: 15, weight: .regular)
                            .frame(height: 30)
                        
                        Text(tab.rawValue)
                            .scaledFont(size: 8, weight: .regular)
                    }
                    .foregroundStyle(isActive ? Color.black : Color.white)
                    .frame(width: 66, height: 50)
                    .background {
                        if isActive {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.siriusHover)
                                .matchedGeometryEffect(id: "siriusActivePill", in: animation)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.rawValue)
                .accessibilityAddTraits(isActive ? .isSelected : [])
                
                if tab.id != Tab.allCases.last?.id {
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(width: 270, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.siriusNavy)
        )
    }
}

// MARK: Apl Nav Bar
#Preview("Applicant") {
    NavigationBar(selectedTab: .constant(AplNavigationTab.home))
        .appBg()
}

// MARK: Emp Nav Bar
#Preview("Employer") {
    NavigationBar(selectedTab: .constant(EmpNavigationTab.home))
        .appBg()
}
