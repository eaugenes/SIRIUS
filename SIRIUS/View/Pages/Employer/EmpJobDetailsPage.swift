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
                        .scaledFont(size: 14, weight: .medium)
                        .foregroundStyle(Color.siriusInk)
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
        .sheet(isPresented: $showEdit) {
            if let job {
                EmpJobPostingPage(job: job)
            }
        }
        .alert("Can't reopen this job", isPresented: Binding(
            get: { jobController.statusError != nil },
            set: { if !$0 { jobController.statusError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(jobController.statusError ?? "")
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
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 14) {
                    CircleBackButton { dismiss() }
                    Text("Job Details")
                        .scaledFont(size: 24, weight: .medium)
                        .foregroundStyle(Color.white)
                }
                .padding(.top, 12)
                
                infoCard(job)
                statGrid(job)
                pipelineCard(job)
                requirementsCard(job)
                descriptionCard(job)
                actions(job)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
    }
    
    private func panel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) { content() }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.siriusSurface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func infoCard(_ job: Job) -> some View {
        let company = job.companyName.isEmpty ? infoController.displayCompanyName : job.companyName
        return panel {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(job.jobPos)
                        .scaledFont(size: 20, weight: .semibold)
                        .foregroundStyle(Color.siriusInk)
                    Text(company)
                        .scaledFont(size: 13)
                        .foregroundStyle(Color.siriusMuted)
                }
                Spacer()
                Text(job.isFilled ? "Filled" : (job.isActive ? "Active" : "Inactive"))
                    .scaledFont(size: 11, weight: .semibold)
                    .foregroundStyle(job.isFilled ? Color.siriusMatchOrange : (job.isActive ? Color.siriusMatchGreenText : Color.siriusMuted))
                    .padding(.horizontal, 12)
                    .frame(height: 22)
                    .background(Capsule().fill(job.isFilled ? Color.siriusMatchOrange.opacity(0.18) : (job.isActive ? Color.siriusMatchBar.opacity(0.18) : Color.siriusFill)))
            }
            if job.isFilled {
                Label("All \(job.maxHire) position(s) are filled, so this job was closed automatically. Raise the maximum hire to reopen it.",
                      systemImage: "checkmark.seal")
                    .scaledFont(size: 12)
                    .foregroundStyle(Color.siriusMatchOrange)
            }
            Divider().padding(.vertical, 4)
            infoLine("Salary", job.salary > 0 ? "\(job.salaryText) / month" : "Not specified")
            infoLine("Location", job.requiredLoc.isEmpty ? "Any" : job.requiredLoc)
            infoLine("Work Setup", job.workSetup.rawValue)
        }
    }
    
    private func infoLine(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).scaledFont(size: 12).foregroundStyle(Color.siriusMuted)
            Spacer()
            Text(value).scaledFont(size: 13, weight: .semibold).foregroundStyle(Color.siriusInk)
        }
    }
    
    private func statGrid(_ job: Job) -> some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            statCard(aplController.count(forJobID: job.jobID), "Applicants", Color.siriusAction)
            statCard(aplController.count(forJobID: job.jobID, status: .toReview), "To Review", Color.siriusMatchOrange)
            statCard(aplController.count(forJobID: job.jobID, status: .interview), "Interview", Color.siriusLink)
            statCard(aplController.count(forJobID: job.jobID, status: .hired), "Hired", Color.siriusMatchBar)
        }
    }
    
    private func statCard(_ value: Int, _ title: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .scaledFont(size: 28, weight: .semibold)
                .foregroundStyle(Color.white)
            Text(title)
                .scaledFont(size: 12)
                .foregroundStyle(Color.white)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(color))
    }
    
    // Segmented bar of To Review / Interview / Hired out of all applicants
    private func pipelineCard(_ job: Job) -> some View {
        let review = aplController.count(forJobID: job.jobID, status: .toReview)
        let interview = aplController.count(forJobID: job.jobID, status: .interview)
        let hired = aplController.count(forJobID: job.jobID, status: .hired)
        let total = max(review + interview + hired, 1)
        
        return panel {
            Text("Hiring Pipeline")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
            GeometryReader { proxy in
                HStack(spacing: 2) {
                    segment(proxy.size.width, review, total, Color.siriusMatchOrange)
                    segment(proxy.size.width, interview, total, Color.siriusLink)
                    segment(proxy.size.width, hired, total, Color.siriusMatchBar)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Capsule().fill(Color.siriusBarTrack))
                .clipShape(Capsule())
            }
            .frame(height: 12)
            HStack(spacing: 14) {
                legend("To Review \(review)", Color.siriusMatchOrange)
                legend("Interview \(interview)", Color.siriusLink)
                legend("Hired \(hired)", Color.siriusMatchBar)
            }
        }
    }
    
    @ViewBuilder
    private func segment(_ width: CGFloat, _ count: Int, _ total: Int, _ color: Color) -> some View {
        if count > 0 {
            Rectangle().fill(color).frame(width: max(width * CGFloat(count) / CGFloat(total) - 2, 0))
        }
    }
    
    private func legend(_ text: String, _ color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(text).scaledFont(size: 11).foregroundStyle(Color.siriusMuted)
        }
    }
    
    private func requirementsCard(_ job: Job) -> some View {
        let years = job.requiredYrExp
        let yearsText = years <= 0 ? "No minimum" : (years == 1 ? "1 year" : "\(Int(years)) years")
        
        return panel {
            Text("Hiring Requirements")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
            infoLine("Program", job.requiredProgram.isEmpty ? "Any" : job.requiredProgram)
            infoLine("Minimum experience", yearsText)
            infoLine("Core languages", job.requiredLang.isEmpty ? "Any" : job.requiredLang.joined(separator: ", "))
            infoLine("Hired / maximum", "\(aplController.count(forJobID: job.jobID, status: .hired)) / \(job.maxHire)")
        }
    }
    
    private func descriptionCard(_ job: Job) -> some View {
        panel {
            Text("About the Role")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
            Text(job.jobDesc.isEmpty ? "No description added." : job.jobDesc)
                .scaledFont(size: 13)
                .foregroundStyle(Color.siriusMuted)
        }
    }
    
    private func actions(_ job: Job) -> some View {
        VStack(spacing: 10) {
            Button { showApplicants = true } label: {
                Text("View Applicants")
                    .scaledFont(size: 17, weight: .semibold)
                    .foregroundStyle(Color.siriusInk)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 52)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.siriusSurface))
            }
            SiriusButton(title: "Edit Job", isFilled: false) { showEdit = true }
            SiriusButton(title: job.isActive ? "Mark as Inactive" : (job.isFilled ? "Reopen Job" : "Mark as Active"), isFilled: false) {
                jobController.toggleStatus(of: job)
            }
            SiriusButton(title: "Delete Job", isFilled: false) { confirmDelete = true }
        }
    }
}
