//
//  ScheduleInterviewOverlay.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI

private struct ScheduleInterviewOverlay: ViewModifier {
    
    @ObservedObject var controller: EmpAplStatusController
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let target = controller.interviewTarget {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { controller.cancelScheduling() }
                    .transition(.opacity)
                
                ScheduleInterviewDialog(
                    applicantName: target.name,
                    title: controller.isRescheduling ? "Reschedule Interview" : "Schedule Interview",
                    sendTitle: controller.isRescheduling ? "Save" : "Send",
                    initial: controller.isRescheduling ? controller.interview(for: target) : nil,
                    onSend: { date, location, message in
                        controller.scheduleInterview(date: date, location: location, message: message)
                    },
                    onCancel: {
                        controller.cancelScheduling()
                    }
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: controller.interviewTarget?.id)
    }
}

extension View {
    func scheduleInterviewOverlay(_ controller: EmpAplStatusController) -> some View {
        modifier(ScheduleInterviewOverlay(controller: controller))
    }
}
