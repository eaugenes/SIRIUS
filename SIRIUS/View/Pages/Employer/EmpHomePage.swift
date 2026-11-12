//
//  EmpHomePage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/23/26.
//

import SwiftUI

struct EmpHomePage: View {
    
    @Binding var selectedTab: EmpNavigationTab
    
    @EnvironmentObject private var infoController: EmpInfoController
    @EnvironmentObject private var aplController: EmpAplStatusController
    
    @State private var jobPostingScreen = false
    @State private var interviewsScreen = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 26),
        GridItem(.flexible(), spacing: 26)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    greeting
                    Spacer(minLength: 8)
                    NotificationBell()
                }
                .padding(.top, 20)
                .padding(.leading, 13)
                .padding(.bottom, 30)
                
                EmpAverageMatchCard(percentage: aplController.averageMatch)
                    .padding(.bottom, 13)
                
                LazyVGrid(columns: columns, spacing: 13) {
                    EmpStatCard(value: aplController.totalCount, title: "Applicants")
                    EmpStatCard(value: aplController.toReviewCount, title: "To Review")
                    EmpStatCard(value: aplController.interviewCount, title: "Interview")
                    EmpStatCard(value: aplController.hiredCount, title: "Hired")
                }
                .padding(.bottom, 13)
                
                interviewsCard
                    .padding(.bottom, 29)
                
                quickActions
                    .padding(.horizontal, -6)
                    .padding(.bottom, 24)
                
                Text("Recent Activity")
                    .scaledFont(size: 18, weight: .medium)
                    .foregroundStyle(Color.siriusText)
                    .padding(.bottom, 12)
                
                LazyVStack(spacing: 14) {
                    ForEach(infoController.recentActivity) { activity in
                        EmpActivityCard(activity: activity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, NavBarMetrics.clearance + 8)          // room for the bottom bar
        }
        .scrollIndicators(.hidden)
        .appBg()
        .sheet(isPresented: $jobPostingScreen) {
            EmpJobPostingPage()
        }
        .navigationDestination(isPresented: $interviewsScreen) {
            // Pass the objects in: tab pages live in a TabView, so SwiftUI hosts this page outside the
            // tab's environment and it would not find them otherwise (crash: "No ObservableObject ... found")
            EmpInterviewsPage()
                .environmentObject(aplController)
        }
    }
    
    // Opens the Interviews page: upcoming interviews and the ones waiting for a decision
    private var interviewsCard: some View {
        Button {
            interviewsScreen = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .scaledFont(size: 18)
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.siriusNavy))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Interviews")
                        .scaledFont(size: 14, weight: .semibold)
                        .foregroundStyle(Color.siriusText)
                    Text("\(aplController.upcomingInterviewCount) upcoming \u{00B7} \(aplController.awaitingDecisionCount) awaiting decision")
                        .scaledFont(size: 11)
                        .foregroundStyle(Color.siriusTextSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.forward")
                    .scaledFont(size: 16)
                    .foregroundStyle(Color.siriusText)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .frame(height: 61)
            .background(Color.siriusSurface)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.25), radius: 2, x: 4, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens the interview schedule and status tracker")
    }
    
    // "Greetings, ABC Company!"
    private var greeting: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Greetings,")
                .scaledFont(size: 20, weight: .light)
            
            Text("\(infoController.displayCompanyName)!")
                .scaledFont(size: 25, weight: .medium)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(Color.white)
    }
    
    // "Quick Action  [Job Posting +]  [Review Applicants 👥]"
    private var quickActions: some View {
        HStack(spacing: 15) {
            Text("Quick Action")
                .scaledFont(size: 15, weight: .medium)
                .foregroundStyle(Color.siriusText)
            
            HStack(spacing: 13) {
                quickActionButton(title: "Job Posting", icon: "plus", fontSize: 10) {
                    jobPostingScreen = true
                }
                
                quickActionButton(title: "Review Applicants", icon: "person.2", fontSize: 9) {
                    aplController.selectedFilter = .toReview
                    withAnimation(.spring(duration: 0.3, bounce: 0.3)) {
                        selectedTab = .applicants
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.siriusSurface)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 4)
    }
    
    private func quickActionButton(title: String, icon: String, fontSize: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .scaledFont(size: fontSize, weight: .bold)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 50, alignment: .leading)
                
                Spacer(minLength: 0)
                
                Image(systemName: icon)
                    .scaledFont(size: 18)
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 9)
            .frame(width: 95, height: 40)
            .background(Color.siriusNavy)
            .cornerRadius(5)
            .shadow(color: Color.black.opacity(0.5), radius: 2, x: 2, y: 2)
        }
    }
}

#Preview {
    NavigationStack {
        EmpHomePage(selectedTab: .constant(.home))
            .environmentObject(EmpInfoController.sample())
            .environmentObject(EmpJobController(jobs: EmpJobController.sampleJobs))
            .environmentObject(EmpAplStatusController(applicants: EmpAplStatusController.sampleApplicants))
    }
}
