//
//  EmpJobPostingPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/13/26.
//

import SwiftUI
import UIKit           // UIKeyboardType / UIImage

// Employer "Job Posting" form (Figma: Job Posting (Employer))
struct EmpJobPostingPage: View {
    
    @EnvironmentObject private var infoController: EmpInfoController
    @EnvironmentObject private var jobController: EmpJobController
    
    @Environment(\.dismiss) private var dismiss
    
    var job: Job? = nil                 // when set, the form edits this job instead of posting a new one
    
    // Form input (raw text; EmpJobController validates it on Post)
    @State private var position = ""
    @State private var jobDescription = ""
    @State private var selectedPrograms: [String] = []
    @State private var yearsOfExperience = 1
    @State private var coreLanguages = ""
    @State private var workSetup: WorkSetup = .onSite
    @State private var preferredLocation = ""
    @State private var maxHire = ""
    @State private var salary = ""
    @State private var loadedJob = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar: X (cancel) on the left, title centred
            ZStack {
                Text(job == nil ? "Job Posting" : "Edit Job")
                    .scaledFont(size: 20, weight: .semibold)
                    .foregroundStyle(Color.siriusInk)
                
                HStack {
                    Button {
                        jobController.postError = nil
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .scaledFont(size: 15, weight: .semibold)
                            .foregroundStyle(Color.siriusInk)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.siriusFieldFill))
                            .overlay(Circle().strokeBorder(Color.siriusFieldBorder, lineWidth: 1))
                    }
                    .accessibilityLabel("Cancel")
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 8)
            
            ScrollView {
                VStack(spacing: 10) {
                    AppTextField(
                        title: "Job Position",
                        placeholder: "Enter job position",
                        text: $position
                    )
                    
                    AppTextField(
                        title: "Job Description",
                        placeholder: "Enter job description",
                        text: $jobDescription,
                        isMultiline: true,
                        multilineHeight: 105
                    )
                    
                    ProgramMultiDropdown(
                        title: "Program",
                        programs: ProgramsList.programs,
                        selectedPrograms: $selectedPrograms,
                        borderColor: .siriusFieldBorder
                    )
                    
                    AppStepper(
                        title: "Years of Experience",
                        value: $yearsOfExperience,
                        range: 0...30
                    )
                    
                    AppTextField(
                        title: "Core Languages",
                        placeholder: "e.g., Python, C++",
                        text: $coreLanguages
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    
                    WorkSetupPicker(
                        title: "Work Setup",
                        selection: $workSetup
                    )
                    
                    AppTextField(
                        title: "Preferred Location",
                        placeholder: "Enter preferred applicants\u{2019} location",
                        text: $preferredLocation
                    )
                    
                    AppTextField(
                        title: "Salary (per month)",
                        placeholder: "e.g. 25000",
                        text: digitsOnly($salary),
                        prefix: "\u{20B1}",
                        keyboardType: .numberPad
                    )
                    
                    AppTextField(
                        title: "Maximum Hire",
                        placeholder: "e.g. 3 applicants",
                        text: $maxHire,
                        keyboardType: .numberPad
                    )
                    
                    FormErrorText(message: jobController.postError)
                        .padding(.top, 6)
                    
                    SiriusButton(title: job == nil ? "Post" : "Save") {
                        post()
                    }
                    .padding(.top, jobController.postError == nil ? 20 : 6)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.siriusSurface.ignoresSafeArea())          // white panel like the sign up pages
        .presentationDetents([.medium, .large])                       // opens half way, drag up for full screen
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
        .presentationBackground(Color.siriusSurface)
        .onAppear {
            jobController.postError = nil
            loadJobIfEditing()
        }
        .onDisappear { jobController.postError = nil }
    }
    
    // Binding that drops everything except the digits 0-9 (also blocks pasted letters/symbols)
    private func digitsOnly(_ source: Binding<String>) -> Binding<String> {
        Binding(
            get: { source.wrappedValue },
            set: { source.wrappedValue = $0.filter { $0.isASCII && $0.isNumber } }
        )
    }
    
    // Pre-fills the form once when editing an existing job
    private func loadJobIfEditing() {
        guard let job, !loadedJob else { return }
        loadedJob = true
        position = job.jobPos
        jobDescription = job.jobDesc
        selectedPrograms = Matching.parsePrograms(job.requiredProgram)
        yearsOfExperience = Int(job.requiredYrExp)
        coreLanguages = job.requiredLang.joined(separator: ", ")
        workSetup = job.workSetup
        preferredLocation = job.requiredLoc
        maxHire = String(job.maxHire)
        salary = job.salary > 0 ? String(job.salary) : ""
    }
    
    private func post() {
        let didPost = jobController.submitJob(
            companyID: infoController.company.cmpId,
            position: position,
            description: jobDescription,
            program: selectedPrograms.joined(separator: ", "),
            yearsOfExperience: yearsOfExperience,
            coreLanguages: coreLanguages,
            workSetup: workSetup,
            preferredLocation: preferredLocation,
            maxHireText: maxHire,
            salaryText: salary,
            editing: job
        )
        
        guard didPost else { return }
        
        infoController.logActivity(
            icon: "briefcase",
            title: job == nil ? "New Job Posted" : "Job Updated",
            jobPosition: position.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EmpJobPostingPage()
            .environmentObject(EmpInfoController.sample())
            .environmentObject(EmpJobController(jobs: []))
    }
}
