//
//  ApplicationsView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct ApplicationStatusPage: View {
    
    @EnvironmentObject private var controller: AplApplicationsController
    @State private var selectedApplicationID: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("My Applications")
                .scaledFont(size: 32, weight: .medium)
                .foregroundColor(.white)
                .padding(.top, 85)
                .padding(.leading, 32)
            
            HStack(spacing: 0) {
                ForEach(ApplicationStatus.tabs) { status in
                    Button(action: {            // Controller updates state, triggering a view redraw
                        withAnimation(.easeInOut(duration: 0.2)) {
                            controller.selectedStatus = status
                        }
                    }) {
                        Text(status.rawValue)
                            .accessibilityAddTraits(controller.selectedStatus == status ? .isSelected : [])
                            .scaledFont(size: 12, weight: .medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(controller.selectedStatus == status ? Color.siriusNavy : Color.clear)
                            .foregroundStyle(controller.selectedStatus == status ? Color.white : Color.siriusText)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(3)
            .frame(maxWidth: 343)
            .frame(height: 44)
            .background(Color.siriusSurface)
            .clipShape(Capsule())
            .padding(.top, 12)
            .padding(.leading, 30)
            
            if controller.filteredApplications.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "folder.badge.questionmark")
                        .scaledFont(size: 50)
                        .foregroundColor(.white.opacity(0.6))
                    Text("No applications found")
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)
                    Text("You are applied automatically to jobs that match you in the green (\(MatchRules.greenMinimum)% or more).")
                        .scaledFont(size: 11)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {            // Filtered List View
                ScrollView {
                    VStack(spacing: 17) {
                        ForEach(controller.filteredApplications) { app in
                            Button {
                                selectedApplicationID = app.id
                            } label: {
                                JobApplicationCard(application: app, showsNewBadge: controller.hasNewInterview(app))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 14)
                    .padding(.leading, 34)
                    .padding(.bottom, NavBarMetrics.clearance + 28)          // room for the bottom bar
                }
                .scrollIndicators(.hidden)
                .refreshable { await JobBoard.shared.reload(silent: true) }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .ignoresSafeArea(.container, edges: .top)
        .appBg()
        .boardLoadState()
        .navigationDestination(item: $selectedApplicationID) { id in
            // Pass the objects in: tab pages live in a TabView, so SwiftUI hosts this page outside the
            // tab's environment and it would not find them otherwise (crash: "No ObservableObject ... found")
            ApplicationDetailsPage(applicationID: id)
                .environmentObject(controller)
        }
    }
}

#Preview {
    ApplicationStatusPage()
        .environmentObject(AplApplicationsController(board: JobBoard()))
}
