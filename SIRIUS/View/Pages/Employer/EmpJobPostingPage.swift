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
    @State private var program = ProgramsList.programs.first?.name ?? ""
    @State private var yearsOfExperience = 1
    @State private var coreLanguages = ""
    @State private var workSetup: WorkSetup = .onSite
    @State private var preferredLocation = ""
    @State private var maxHire = ""
    @State private var loadedJob = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                PageHeader(title: job == nil ? "Job Posting" : "Edit Job", titleSize: 25) {
                    jobController.postError = nil
                    dismiss()
                }
                .padding(.top, 12)
                .padding(.bottom, 4)
                
                AppTextField(
                    title: "Job Position",
                    placeholder: "Enter job position",
                    text: $position,
                    borderColor: .siriusPanel
                )
                
                AppTextField(
                    title: "Job Description",
                    placeholder: "Enter job description",
                    text: $jobDescription,
                    isMultiline: true,
                    borderColor: .siriusPanel,
                    multilineHeight: 105
                )
                
                ProgramDropdown(
                    title: "Program",
                    programs: ProgramsList.programs,
                    selectedProgram: $program,
                    borderColor: .siriusPanel
                )
                
                AppStepper(
                    title: "Years of Experience",
                    value: $yearsOfExperience,
                    range: 0...30,
                    borderColor: .siriusPanel
                )
                
                AppTextField(
                    title: "Core Languages",
                    placeholder: "e.g., Python, C++",
                    text: $coreLanguages,
                    borderColor: .siriusPanel
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                
                WorkSetupPicker(
                    title: "Work Setup",
                    selection: $workSetup,
                    borderColor: .siriusPanel
                )
                
                AppTextField(
                    title: "Preferred Location",
                    placeholder: "Enter preferred applicants’ location",
                    text: $preferredLocation,
                    borderColor: .siriusPanel
                )
                
                AppTextField(
                    title: "Maximum Hire",
                    placeholder: "e.g. 3 applicants",
                    text: $maxHire,
                    borderColor: .siriusPanel,
                    keyboardType: .numberPad
                )
                
                FormErrorText(message: jobController.postError)
                    .padding(.top, 6)
                
                SiriusButton(title: job == nil ? "Post" : "Save") {
                    post()
                }
                .shadow(color: Color.black.opacity(0.5), radius: 1, x: 0, y: 4)
                .padding(.top, jobController.postError == nil ? 20 : 6)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .appBg()
        .navigationBarBackButtonHidden(true)
        .onAppear { loadJobIfEditing() }
    }
    
    // Pre-fills the form once when editing an existing job
    private func loadJobIfEditing() {
        guard let job, !loadedJob else { return }
        loadedJob = true
        position = job.jobPos
        jobDescription = job.jobDesc
        program = job.requiredEduc
        yearsOfExperience = Int(job.requiredYrExp)
        coreLanguages = job.requiredLang.joined(separator: ", ")
        workSetup = job.workSetup
        preferredLocation = job.requiredLoc
        maxHire = String(job.maxHire)
    }
    
    private func post() {
        let didPost = jobController.submitJob(
            companyID: infoController.company.cmpId,
            position: position,
            description: jobDescription,
            program: program,
            yearsOfExperience: yearsOfExperience,
            coreLanguages: coreLanguages,
            workSetup: workSetup,
            preferredLocation: preferredLocation,
            maxHireText: maxHire,
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
