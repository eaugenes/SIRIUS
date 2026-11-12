//
//  InterviewScheduleCard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI

struct InterviewScheduleCard: View {
    
    let role: String
    let company: String
    let interview: Interview
    var showsNewBadge: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 0) {
                Text(interview.date.formatted(.dateTime.month(.abbreviated)).uppercased())
                    .scaledFont(size: 10, weight: .bold)
                Text(interview.date.formatted(.dateTime.day()))
                    .scaledFont(size: 22, weight: .bold)
            }
            .foregroundStyle(Color.white)
            .frame(width: 52, height: 56)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.siriusNavy))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(role)
                    .scaledFont(size: 14, weight: .bold)
                    .foregroundStyle(Color.siriusText)
                    .lineLimit(1)
                Text(company)
                    .scaledFont(size: 11, weight: .medium)
                    .foregroundStyle(Color.siriusText)
                    .lineLimit(1)
                Text(interview.date.formatted(date: .omitted, time: .shortened) + " \u{00B7} " + interview.location)
                    .scaledFont(size: 10, weight: .light)
                    .foregroundStyle(Color.siriusText)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
            
            if showsNewBadge {
                Text("New")
                    .scaledFont(size: 8, weight: .bold)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .frame(height: 16)
                    .background(Capsule().fill(Color.red))
            }
        }
        .padding(.horizontal, 14)
        .fluidFrame(width: 333, height: 88)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.siriusSurface))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Interview for \(role) at \(company), \(interview.date.formatted(date: .complete, time: .shortened)), \(interview.location)")
        .accessibilityHint("Opens application details")
    }
}

// Full interview details inside Application Details
struct InterviewDetailsPanel: View {
    
    let role: String
    let company: String
    let interview: Interview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Your interview", systemImage: "calendar")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
            
            row("Job", role)
            row("Company", company)
            Divider()
            row("Date", interview.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
            row("Time", interview.date.formatted(date: .omitted, time: .shortened))
            row("Place", interview.location)
            
            if !interview.message.isEmpty {
                Divider()
                Text("Message from the employer")
                    .scaledFont(size: 12)
                    .foregroundStyle(Color.siriusMuted)
                Text(interview.message)
                    .scaledFont(size: 13)
                    .foregroundStyle(Color.siriusInk)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .scaledFont(size: 12)
                .foregroundStyle(Color.siriusMuted)
            Spacer(minLength: 12)
            Text(value)
                .scaledFont(size: 13, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
                .multilineTextAlignment(.trailing)
        }
    }
}
