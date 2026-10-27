//
//  MainTabView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/14/26.
//

import SwiftUI

struct MainTabView: View {
    
    let role: UserRole
    
    // Employer data (only used when role == .employer)
    @ObservedObject var infoController: EmpInfoController           // created during employer sign up / log in
    @StateObject private var jobController: EmpJobController
    @StateObject private var aplController: EmpAplStatusController
    
    // Applicant data (only used when role == .applicant)
    @ObservedObject var applicantController: AplInfoController      // created during applicant sign up / log in
    @StateObject private var jobsController: AplJobsController
    @StateObject private var applicationsController: AplApplicationsController
    
    // Selected tab for each side
    @State private var aplTab: AplNavigationTab = .home
    @State private var empTab: EmpNavigationTab = .home
    
    init(
        role: UserRole = .applicant,
        infoController: EmpInfoController = EmpInfoController(),
        applicantController: AplInfoController = AplInfoController(applicant: AplInfoController.blankApplicant())
    ) {
        self.role = role
        self.infoController = infoController
        self.applicantController = applicantController
        
        // Employer: only this company's jobs and applicants
        let companyID = infoController.company.cmpId
        _jobController = StateObject(wrappedValue: EmpJobController(
            companyID: companyID,
            companyName: infoController.company.cmpName
        ))
        _aplController = StateObject(wrappedValue: EmpAplStatusController(companyID: companyID))
        
        // Applicant: job feed and applications of this applicant
        _jobsController = StateObject(wrappedValue: AplJobsController(info: applicantController))
        _applicationsController = StateObject(wrappedValue: AplApplicationsController(applicantID: applicantController.applicant.id))
    }
    
    // Opens the right side for a saved account (used after log in)
    init(account: UserAccount) {
        switch account.role {
        case .applicant:
            self.init(role: .applicant, applicantController: AplInfoController(account: account))
        case .employer:
            self.init(role: .employer, infoController: EmpInfoController(account: account))
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            switch role {
            case .applicant:
                applicantTabs
            case .employer:
                employerTabs
            }
        }
        .ignoresSafeArea(.keyboard)     // to overlay components in the screen when keyboard is on
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Applicant
    
    @ViewBuilder
    private var applicantTabs: some View {
        TabView(selection: $aplTab) {
            AplHomePage(selectedTab: $aplTab)
                .tag(AplNavigationTab.home)
                .toolbar(.hidden, for: .tabBar)
            
            AplJobDiscoveryPage()
                .tag(AplNavigationTab.jobs)
                .toolbar(.hidden, for: .tabBar)
            
            ApplicationStatusPage()
                .tag(AplNavigationTab.applications)
                .toolbar(.hidden, for: .tabBar)
            
            AplAccountPage()
                .tag(AplNavigationTab.profile)
                .toolbar(.hidden, for: .tabBar)
        }
        .environmentObject(applicantController)
        .environmentObject(jobsController)
        .environmentObject(applicationsController)
        
        NavigationBar(selectedTab: $aplTab)
            .padding(10)
    }
    
    // MARK: - Employer
    
    @ViewBuilder
    private var employerTabs: some View {
        TabView(selection: $empTab) {
            EmpHomePage(selectedTab: $empTab)
                .tag(EmpNavigationTab.home)
                .toolbar(.hidden, for: .tabBar)
            
            EmpManageJobsPage()
                .tag(EmpNavigationTab.jobs)
                .toolbar(.hidden, for: .tabBar)
            
            EmpApplicantsOverviewPage()
                .tag(EmpNavigationTab.applicants)
                .toolbar(.hidden, for: .tabBar)
            
            EmpAccountPage()
                .tag(EmpNavigationTab.profile)
                .toolbar(.hidden, for: .tabBar)
        }
        .environmentObject(infoController)
        .environmentObject(jobController)
        .environmentObject(aplController)
        
        // Hidden while the Schedule Interview modal is open so the dimmed overlay covers it
        if aplController.interviewTarget == nil {
            NavigationBar(selectedTab: $empTab)
                .padding(10)
                .transition(.opacity)
        }
    }
}

#Preview("Applicant") {
    NavigationStack {
        MainTabView()
    }
}

#Preview("Employer") {
    NavigationStack {
        MainTabView(role: .employer, infoController: EmpInfoController.sample())
    }
}
