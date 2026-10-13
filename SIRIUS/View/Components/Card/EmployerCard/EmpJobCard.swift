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
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(job.applicantCount) Applicants")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.black)
                    
                    Text("Posted on \(postedText)")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.siriusTextSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.forward")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.black)
        }
        .padding(.horizontal, 16)
        .frame(width: 338, height: 65)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 4, y: 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    EmpJobCard(job: EmpJobController.sampleJobs[0])
        .appBg()
}
