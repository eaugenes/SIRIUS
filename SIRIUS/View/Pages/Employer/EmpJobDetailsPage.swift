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
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showApplicants) {
            if let job {
                EmpManageApplicantsPage(job: job)
                    .environmentObject(aplController)
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
        let programs = Matching.parsePrograms(job.requiredProgram)

        return panel {
            Text("Hiring Requirements")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusInk)

            HStack(alignment: .top) {
                Text("Program").scaledFont(size: 12).foregroundStyle(Color.siriusMuted)
                Spacer(minLength: 12)
                VStack(alignment: .trailing, spacing: 2) {
                    if programs.isEmpty {
                        Text("Any").scaledFont(size: 11, weight: .semibold).foregroundStyle(Color.siriusInk)
                    } else {
                        ForEach(programs, id: \.self) { program in
                            Text(program)
                                .scaledFont(size: 11, weight: .semibold)
                                .foregroundStyle(Color.siriusInk)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
            infoLine("Minimum experience", yearsText)
            infoLine("Core languages", job.requiredLang.isEmpty ? "Any" : job.requiredLang.joined(separator: ", "))
            infoLine("Hire Target", "\(aplController.count(forJobID: job.jobID, status: .hired)) / \(job.maxHire)")
        }
    }

    private func descriptionCard(_ job: Job) -> some View {
        let sentences = Self.sentences(job.jobDesc)
        let overview = sentences.first ?? ""
        let duties = Array(sentences.dropFirst())

        return panel {
            Text("About the Role")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusInk)

            if sentences.isEmpty {
                Text("No description added.")
                    .scaledFont(size: 13)
                    .foregroundStyle(Color.siriusMuted)
            } else {
                sectionLabel("Overview")
                Text(overview)
                    .scaledFont(size: 13)
                    .foregroundStyle(Color.siriusInk)
                    .fixedSize(horizontal: false, vertical: true)

                if !duties.isEmpty {
                    sectionLabel("Key Responsibilities")
                        .padding(.top, 4)
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(duties.enumerated()), id: \.offset) { _, duty in
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("\u{2022}")
                                    .scaledFont(size: 13, weight: .bold)
                                    .foregroundStyle(Color.siriusAction)
                                Text(duty)
                                    .scaledFont(size: 13)
                                    .foregroundStyle(Color.siriusInk)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }

            sectionLabel("Work Arrangement")
                .padding(.top, 4)
            HStack(spacing: 8) {
                tag(job.workSetup.rawValue, icon: "desktopcomputer")
                tag(job.requiredLoc.isEmpty ? "Any location" : job.requiredLoc, icon: "mappin.and.ellipse")
                tag("\(job.maxHire) opening\(job.maxHire == 1 ? "" : "s")", icon: "person.2")
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .scaledFont(size: 10, weight: .bold)
            .tracking(0.8)
            .foregroundStyle(Color.siriusMuted)
    }

    private func tag(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).scaledFont(size: 10)
            Text(text).scaledFont(size: 11, weight: .medium).lineLimit(1).minimumScaleFactor(0.8)
        }
        .foregroundStyle(Color.siriusInk)
        .padding(.horizontal, 8)
        .frame(height: 24)
        .background(Capsule().fill(Color.siriusFieldFill))
        .overlay(Capsule().strokeBorder(Color.siriusFieldBorder, lineWidth: 1))
    }

    private static func sentences(_ text: String) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        var result: [String] = []
        trimmed.enumerateSubstrings(in: trimmed.startIndex..., options: .bySentences) { sentence, _, _, _ in
            if let sentence {
                let clean = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
                if !clean.isEmpty { result.append(clean) }
            }
        }
        return result.isEmpty ? [trimmed] : result
    }

    private func actions(_ job: Job) -> some View {
        VStack(spacing: 10) {
            actionButton("View Applicants", foreground: .white, background: .siriusNavy) {
                showApplicants = true
            }
            actionButton("Edit Job", foreground: .siriusNavy, background: .white) {
                showEdit = true
            }
            HStack(spacing: 10) {
                actionButton(job.isActive ? "Mark as Inactive" : (job.isFilled ? "Reopen Job" : "Mark as Active"),
                             foreground: .siriusNavy, background: .white) {
                    jobController.toggleStatus(of: job)
                }
                actionButton("Delete Job", foreground: .white, background: .siriusDanger) {
                    confirmDelete = true
                }
            }
        }
    }

    private func actionButton(_ title: String, foreground: Color, background: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .background(RoundedRectangle(cornerRadius: 16).fill(background))
                .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 2)
        }
    }
}
