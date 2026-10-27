//
//  EmpJobCard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/6/26.
//

import SwiftUI

struct EmpJobCard: View {
    let job: Job
    
    private var postedText: String {
        job.datePosted.formatted(.dateTime.month(.abbreviated).day().year())
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(job.jobPos)
                    .scaledFont(size: 13, weight: .medium)
                    .foregroundStyle(Color.siriusText)
                    .lineLimit(1)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(job.isFilled ? "Filled \u{00B7} \(job.applicantCount) Applicants" : "\(job.applicantCount) Applicants")
                        .scaledFont(size: 10)
                        .foregroundStyle(Color.siriusText)
                    
                    Text("Posted on \(postedText)")
                        .scaledFont(size: 8)
                        .foregroundStyle(Color.siriusTextSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.forward")
                .scaledFont(size: 20, weight: .regular)
                .foregroundStyle(Color.siriusText)
        }
        .padding(.horizontal, 16)
        .fluidFrame(width: 338, height: 65)
        .background(Color.siriusSurface)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 4, y: 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(job.jobPos), \(job.isFilled ? "filled, " : "")\(job.applicantCount) applicants, posted on \(postedText)")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    EmpJobCard(job: EmpJobController.sampleJobs[0])
        .appBg()
}
