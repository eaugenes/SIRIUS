//
//  CountBadge.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/18/26.
//

import SwiftUI

struct CountBadge: View {

    let count: Int

    var body: some View {
        Text("\(count)")
            .scaledFont(size: 9, weight: .bold)
            .foregroundStyle(Color.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, count > 9 ? 4 : 0)
            .frame(minWidth: 16, minHeight: 16)
            .background(Capsule().fill(count > 0 ? Color.red : Color.siriusStatusWithdrawn))
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 12) {
        CountBadge(count: 0)
        CountBadge(count: 5)
        CountBadge(count: 12)
    }
    .padding()
    .appBg()
}
