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
            
            // Segmented control: All | Applied | Interview | Accepted | Rejected
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
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(controller.selectedStatus == status ? Color.siriusNavy : Color.clear)
                            .foregroundStyle(controller.selectedStatus == status ? Color.white : Color.black)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(3)
            .fluidFrame(width: 343, height: 44)
            .background(Color.siriusSurface)
            .clipShape(Capsule())
            .padding(.top, 12)
            .padding(.leading, 30)
            
            // Dynamic Content Area
            if controller.filteredApplications.isEmpty {            // Empty State UI
                Spacer()
                VStack {
                    Image(systemName: "folder.badge.questionmark")
                        .scaledFont(size: 50)
                        .foregroundColor(.white.opacity(0.6))
                    Text("No applications found")
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)
                    Text("You are applied automatically to jobs that match you at 60% or more.")
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
                                JobApplicationCard(application: app)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 14)
                    .padding(.leading, 34)
                    .padding(.bottom, 120)          // room for the bottom bar
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .ignoresSafeArea(.container, edges: .top)
        .appBg()
        .boardLoadState()
        .navigationDestination(item: $selectedApplicationID) { id in
            ApplicationDetailsPage(applicationID: id)
        }
    }
}

#Preview {
    ApplicationStatusPage()
        .environmentObject(AplApplicationsController(board: JobBoard()))
}
