//
//  MatchSummaryPanel.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/18/26.
//

import SwiftUI

struct MatchSummaryPanel: View {

    let summary: MatchSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Summary")
                .scaledFont(size: 13, weight: .medium)
                .foregroundStyle(Color.siriusInk)

            VStack(spacing: 7) {
                ForEach(summary.rows) { row in
                    HStack(spacing: 8) {
                        Text(row.title)
                            .scaledFont(size: 11)
                            .foregroundStyle(Color.siriusInk)
                            .lineLimit(1)
                            .frame(width: 74, alignment: .leading)

                        bar(score: row.score, outOf: row.outOf)

                        Text("\(row.score)/\(row.outOf)")
                            .scaledFont(size: 11, weight: .medium)
                            .foregroundStyle(Color.siriusInk)
                            .frame(width: 38, alignment: .trailing)
                    }
                }
            }

            gapLine
                .padding(.top, 1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.25), radius: 5)
        .accessibilityElement(children: .combine)
    }

    private func bar(score: Int, outOf: Int) -> some View {
        let ratio = outOf > 0 ? min(1, max(0, Double(score) / Double(outOf))) : 0
        return Capsule()
            .fill(Color.siriusBarTrack)
            .frame(height: 5)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(Color.siriusMatchBar)
                        .frame(width: proxy.size.width * ratio)
                }
            }
    }

    @ViewBuilder
    private var gapLine: some View {
        if let gap = summary.gap {
            Text("Gap: \(gap)")
                .scaledFont(size: 11, weight: .medium)
                .foregroundStyle(Color.siriusStatusRejected)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text("No gaps")
                .scaledFont(size: 11, weight: .medium)
                .foregroundStyle(Color.siriusMatchGreenText)
        }
    }
}

#Preview {
    MatchSummaryPanel(
        summary: MatchSummary(
            rows: [
                MatchSummaryRow(title: "Program", score: 20, outOf: 20),
                MatchSummaryRow(title: "Experience", score: 20, outOf: 20),
                MatchSummaryRow(title: "Languages", score: 49, outOf: 50),
                MatchSummaryRow(title: "Work setup", score: 10, outOf: 10)
            ],
            gap: "Languages | Kotlin (1/5 Jobs)"
        )
    )
    .fluidFrame(width: 360)
    .appBg()
}
