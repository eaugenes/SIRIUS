//
//  ApplicationStatusPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct ApplicationStatusPage: View {

    @EnvironmentObject private var controller: AplApplicationsController
    @State private var selectedApplicationID: UUID?

    var body: some View {
        NavigationStack {
            content
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(item: $selectedApplicationID) { id in
                    ApplicationDetailsPage(applicationID: id, onBack: { selectedApplicationID = nil })
                        .environmentObject(controller)
                }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("My Applications")
                .scaledFont(size: 32, weight: .medium)
                .foregroundColor(.white)
                .padding(.top, 85)
                .padding(.leading, 32)

            HStack(spacing: 0) {
                ForEach(ApplicationStatus.tabs) { status in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            controller.selectedStatus = status
                        }
                    }) {
                        HStack(spacing: 3) {
                            Text(status.rawValue)
                                .scaledFont(size: 12, weight: .medium)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            CountBadge(count: controller.count(of: status))
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(status.rawValue), \(controller.count(of: status))")
                        .accessibilityAddTraits(controller.selectedStatus == status ? .isSelected : [])
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(controller.selectedStatus == status ? Color.siriusNavy : Color.clear)
                        .foregroundStyle(controller.selectedStatus == status ? Color.white : Color.siriusText)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(3)
            .frame(maxWidth: 343)
            .frame(height: 44)
            .background(Color.siriusSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.siriusBorder, lineWidth: 1))
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
            } else {
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
                    .padding(.bottom, NavBarMetrics.clearance + 28)
                }
                .scrollIndicators(.hidden)
                .refreshable { await JobBoard.shared.reload(silent: true) }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .ignoresSafeArea(.container, edges: .top)
        .appBg()
        .boardLoadState()
    }
}

#Preview {
    ApplicationStatusPage()
        .environmentObject(AplApplicationsController(board: JobBoard()))
}
