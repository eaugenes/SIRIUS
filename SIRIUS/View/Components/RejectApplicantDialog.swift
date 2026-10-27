//
//  RejectApplicantDialog.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

// Employer picks a reason before rejecting / removing an applicant.
// The reason is saved on the application and shown to the applicant.
struct RejectApplicantDialog: View {
    
    let applicantName: String
    var onReject: (_ reason: String) -> Void
    var onCancel: () -> Void
    
    static let reasons = [
        "Does not meet the job requirements",
        "Another candidate was a better match",
        "Position has been filled",
        "Incomplete profile or resume",
        "Other"
    ]
    
    @State private var selectedReason = RejectApplicantDialog.reasons[0]
    @State private var note = ""
    
    private var finalReason: String {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return selectedReason }
        return selectedReason == "Other" ? trimmed : "\(selectedReason): \(trimmed)"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reject \(applicantName)?")
                        .scaledFont(size: 20, weight: .semibold)
                        .foregroundStyle(Color.siriusInk)
                    Text("The applicant will see the reason you choose.")
                        .scaledFont(size: 13)
                        .foregroundStyle(Color.siriusMuted)
                    
                    VStack(spacing: 8) {
                        ForEach(Self.reasons, id: \.self) { reason in
                            Button {
                                selectedReason = reason
                            } label: {
                                HStack {
                                    Text(reason)
                                        .scaledFont(size: 14)
                                        .foregroundStyle(Color.siriusInk)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    Image(systemName: selectedReason == reason ? "largecircle.fill.circle" : "circle")
                                        .foregroundStyle(Color.siriusAction)
                                }
                                .padding(.horizontal, 14)
                                .frame(minHeight: 44)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.siriusFieldFill))
                                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(
                                    selectedReason == reason ? Color.siriusAction : Color.siriusFieldBorder, lineWidth: 1))
                            }
                            .accessibilityAddTraits(selectedReason == reason ? .isSelected : [])
                        }
                    }
                    
                    AppTextField(
                        title: "Note (optional)",
                        placeholder: "Add a short note for the applicant",
                        text: $note,
                        isMultiline: true,
                        multilineHeight: 80
                    )
                    
                    HStack(spacing: 12) {
                        Button("Cancel", action: onCancel)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.siriusAction, lineWidth: 1.5))
                            .foregroundStyle(Color.siriusAction)
                        
                        Button {
                            onReject(finalReason)
                        } label: {
                            Text("Reject")
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color.siriusDanger))
                                .foregroundStyle(Color.white)
                        }
                    }
                    .scaledFont(size: 15, weight: .semibold)
                    .padding(.top, 6)
                }
                .padding(20)
            }
            .background(Color.siriusSurface.ignoresSafeArea())
        }
        .presentationDetents([.large])
    }
}
