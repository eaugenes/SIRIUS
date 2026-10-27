//
//  ApplicationsView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct ApplicationStatusPage: View {
    
    @EnvironmentObject private var controller: AplApplicationsController
    
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 16) {
                Text("My Applications")
                    .font(.system(size: 35, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top, 5)
                
                // Horizontal Segmented Control
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ApplicationStatus.allCases) { status in
                            Button(action: {            // Controller updates state, triggering a view redraw
                                controller.selectedStatus = status
                            }) {
                                Text(status.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                                    .frame(width: 80, height: 30)
                                    .background(controller.selectedStatus == status ? Color(red: 3/255, green: 82/255, blue: 123/255) : Color.clear)
                                    .foregroundStyle(controller.selectedStatus == status ? Color.white : Color.black)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                .background(.white)
                .cornerRadius(100)
                .frame(width: 350, height: 50)
                
                
                // Dynamic Content Area
                if controller.filteredApplications.isEmpty {            // Empty State UI
                    Spacer()
                    VStack {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.6))
                        Text("No applications found")
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 8)
                        Text("You are applied automatically to jobs that match you at 60% or more.")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {            // Filtered List View
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(controller.filteredApplications) { app in
                                JobApplicationCard(application: app)
                            }
                        }
                        .padding(.bottom, 100)          // room for the bottom bar
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .appBg()
    }
}

#Preview {
    ApplicationStatusPage()
        .environmentObject(AplApplicationsController(board: JobBoard()))
}
