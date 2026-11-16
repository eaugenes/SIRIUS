//
//  EmpSegmentedTabs.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/6/26.
//

import SwiftUI

struct EmployerSegmentedTabs<Item: Hashable>: View {
    let items: [Item]
    let title: (Item) -> String
    @Binding var selection: Item
    var width: CGFloat = 370

    @Namespace private var pill

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                let isSelected = selection == item

                Button {
                    withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                        selection = item
                    }
                } label: {
                    Text(title(item))
                        .scaledFont(size: 15, weight: .medium)
                        .foregroundStyle(isSelected ? Color.white : Color.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.siriusNavy)
                                    .matchedGeometryEffect(id: "selectedPill", in: pill)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.siriusSurface))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.siriusBorder, lineWidth: 1))
        .frame(width: width)
    }
}

#Preview {
    VStack(spacing: 20) {
        EmployerSegmentedTabs(
            items: JobListTab.allCases,
            title: { $0.rawValue },
            selection: .constant(JobListTab.active)
        )
        EmployerSegmentedTabs(
            items: EmpApplicantFilter.allCases,
            title: { $0.rawValue },
            selection: .constant(EmpApplicantFilter.toReview)
        )
    }
    .appBg()
}
