//
//  ScheduleInterviewDialog.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/13/26.
//

import SwiftUI

// "Schedule Interview" card shown over Manage Applicants (Figma: Frame 85)
struct ScheduleInterviewDialog: View {
    
    let applicantName: String
    var onSend: (_ date: Date, _ location: String, _ message: String) -> Void
    var onCancel: () -> Void
    
    @State private var date = Date()
    @State private var location = ""
    @State private var message = ""
    @State private var error: String?
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Schedule Interview")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.white)
                
                HStack {
                    Spacer()
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .frame(width: 32, height: 32)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .padding(.top, 10)
            
            Text(applicantName)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Color.white.opacity(0.85))
                .padding(.bottom, 10)
            
            Text("Date & Time")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.bottom, 6)
            
            HStack(spacing: 8) {
                DatePicker("Date", selection: $date, in: Date()..., displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .background(Capsule().fill(Color.white))
                
                DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .background(Capsule().fill(Color.white))
            }
            .environment(\.colorScheme, .light)
            .tint(Color.siriusNavy)
            .padding(.bottom, 20)
            
            VStack(spacing: 10) {
                AppTextField(
                    title: "Location",
                    placeholder: "Enter location",
                    text: $location,
                    titleColor: .white,
                    borderColor: .siriusBorder
                )
                
                AppTextField(
                    title: "Message",
                    placeholder: "Enter message",
                    text: $message,
                    isMultiline: true,
                    titleColor: .white,
                    borderColor: .siriusBorder,
                    multilineHeight: 145
                )
            }
            
            if let error {
                Text(error)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.siriusMatchGreen)
                    .padding(.top, 8)
            }
            
            SiriusButton(title: "Send", isFilled: false) {
                if location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    error = "Please enter the interview location."
                    return
                }
                onSend(date, location, message)
            }
            .padding(.top, 22)
            .padding(.bottom, 22)
        }
        .padding(.horizontal, 23)
        .frame(width: 347)
        .background(Color.siriusPanel)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    ScheduleInterviewDialog(applicantName: "Franck Almareno", onSend: { _, _, _ in }, onCancel: {})
        .appBg()
}
