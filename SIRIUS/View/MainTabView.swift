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
    @ObservedObject var infoController: EmpInfoController           // created during employer sign up
    @StateObject private var jobController = EmpJobController()
    @StateObject private var aplController = EmpAplStatusController()
    
    // Selected tab for each side
    @State private var aplTab: AplNavigationTab = .home
    @State private var empTab: EmpNavigationTab = .home
    
    init(role: UserRole = .applicant, infoController: EmpInfoController = EmpInfoController()) {
        self.role = role
        self.infoController = infoController
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
            AplHomePage()
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
            
            EmpManageApplicantsPage()
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
