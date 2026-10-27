//
//  EmpJobDetailsPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct EmpJobDetailsPage: View {
    
    let jobID: String
    
    @EnvironmentObject private var jobController: EmpJobController
    @EnvironmentObject private var aplController: EmpAplStatusController
    @EnvironmentObject private var infoController: EmpInfoController
    @Environment(\.dismiss) private var dismiss
    
    @State private var showApplicants = false
    @State private var showEdit = false
    @State private var confirmDelete = false
    
    private var job: Job? {
        jobController.jobs.first { $0.jobID == jobID }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let job {
                content(for: job)
            } else {
                VStack(spacing: 12) {
                    Text("This job is no longer available.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.siriusNavy)
                    SiriusButton(title: "Back") { dismiss() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .appBg()
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showApplicants) {
            if let job {
                EmpManageApplicantsPage(job: job)
            }
        }
        .navigationDestination(isPresented: $showEdit) {
            if let job {
                EmpJobPostingPage(job: job)
            }
        }
        .alert("Delete this job?", isPresented: $confirmDelete) {
            Button("Delete", role: .destructive) {
                if let job {
                    jobController.deleteJob(job)
                }
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The job and its applicants will be removed.")
        }
    }
    
    private func content(for job: Job) -> some View {
        let postedText = job.datePosted.formatted(.dateTime.month(.abbreviated).day().year())
        let company = job.companyName.isEmpty ? infoController.displayCompanyName : job.companyName
        
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.black)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white))
                }
                .accessibilityLabel("Back")
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(job.jobPos)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                    Text("\(company) | \(postedText)")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 16)
            
            ScrollView {
                VStack(spacing: 14) {
                    statsRow(job)
                    requirementsCard(job)
                    descriptionCard(job)
                    actions(job)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private func statsRow(_ job: Job) -> some View {
        HStack(spacing: 0) {
            stat(aplController.count(forJobID: job.jobID), "Applicants")
            stat(aplController.count(forJobID: job.jobID, status: .toReview), "To Review")
            stat(aplController.count(forJobID: job.jobID, status: .interview), "Interview")
            stat(aplController.count(forJobID: job.jobID, status: .hired), "Hired")
        }
        .frame(width: 338, height: 70)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
    
    private func stat(_ value: Int, _ title: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.siriusNavy)
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(Color.siriusTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func requirementsCard(_ job: Job) -> some View {
        let years = job.requiredYrExp
        let yearsText = years <= 0 ? "No minimum" : (years == 1 ? "1 year" : "\(Int(years)) years")
        
        return card {
            Text("Requirements")
                .font(.system(size: 13, weight: .medium))
            row("Program", job.requiredEduc.isEmpty ? "Any" : job.requiredEduc)
            row("Minimum experience", yearsText)
            row("Core languages", job.requiredLang.isEmpty ? "Any" : job.requiredLang.joined(separator: ", "))
            row("Work setup", job.workSetup.rawValue)
            row("Preferred location", job.requiredLoc.isEmpty ? "Any" : job.requiredLoc)
            row("Maximum hire", "\(job.maxHire)")
            row("Status", job.isActive ? "Active" : "Inactive")
        }
    }
    
    private func descriptionCard(_ job: Job) -> some View {
        card {
            Text("Job Description")
                .font(.system(size: 13, weight: .medium))
            Text(job.jobDesc.isEmpty ? "No description added." : job.jobDesc)
                .font(.system(size: 11))
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func actions(_ job: Job) -> some View {
        VStack(spacing: 10) {
            SiriusButton(title: "View Applicants") { showApplicants = true }
            SiriusButton(title: "Edit Job", isFilled: false) { showEdit = true }
            SiriusButton(title: job.isActive ? "Mark as Inactive" : "Mark as Active", isFilled: false) {
                jobController.toggleStatus(of: job)
            }
            SiriusButton(title: "Delete Job", isFilled: false) { confirmDelete = true }
        }
    }
    
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(16)
        .frame(width: 338, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
    
    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(Color.siriusTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.trailing)
        }
    }
}
