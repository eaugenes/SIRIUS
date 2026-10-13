//
//  EmpAplCard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/6/26.
//

import SwiftUI

// Applicant row. When selected, the card slides left and reveals
// the envelope (schedule interview) and red X (remove) buttons.
struct EmpAplCard: View {
    
    let applicant: EmpApplicant
    let isSelected: Bool
    var onSelect: () -> Void
    var onSchedule: () -> Void
    var onRemove: () -> Void
    
    private let cardWidth: CGFloat = 354
    private let cardHeight: CGFloat = 74
    private let actionSize: CGFloat = 52
    private let actionSpacing: CGFloat = 4
    
    private var slideDistance: CGFloat {
        actionSize * 2 + actionSpacing * 2
    }
    
    private var experienceText: String {
        applicant.yearsExperience == 1
            ? "1 year work experience"
            : "\(applicant.yearsExperience) years work experience"
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Action buttons stay pinned to the right edge, hidden until selected
            HStack(spacing: actionSpacing) {
                Button(action: onSchedule) {
                    Image(systemName: "envelope")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.black)
                        .frame(width: actionSize, height: actionSize)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 4)
                }
                .disabled(applicant.status != .toReview)        // only "To Review" applicants get invited
                .opacity(applicant.status == .toReview ? 1 : 0.4)
                .accessibilityLabel("Schedule interview")
                
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(Color.white)
                        .frame(width: actionSize, height: actionSize)
                        .background(Color.siriusDanger)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 4)
                }
                .accessibilityLabel("Remove applicant")
            }
            .frame(width: cardWidth, alignment: .trailing)
            .opacity(isSelected ? 1 : 0)
            .allowsHitTesting(isSelected)
            
            card
                .offset(x: isSelected ? -slideDistance : 0)
                .onTapGesture(perform: onSelect)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            let horizontal = value.translation.width
                            guard abs(horizontal) > abs(value.translation.height) else { return }
                            if horizontal < -30 && !isSelected { onSelect() }     // swipe left: reveal
                            if horizontal > 30 && isSelected { onSelect() }       // swipe right: hide
                        }
                )
        }
        .frame(width: cardWidth, height: cardHeight + 10)
        .animation(.spring(duration: 0.3, bounce: 0.2), value: isSelected)
    }
    
    private var card: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(applicant.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                
                Text(applicant.degree)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.black)
                
                Text(experienceText)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.black)
            }
            
            Spacer(minLength: 4)
            
            VStack(spacing: 3) {
                ForEach(Array(applicant.coreLanguages.prefix(3)), id: \.self) { language in
                    Text(language)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .frame(width: 74, height: 12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.siriusNavy))
                        .shadow(color: Color.black.opacity(0.25), radius: 1.5, x: 0, y: 3)
                }
            }
            
            matchIndicator
                .padding(.leading, 3)
        }
        .padding(.leading, 11)
        .padding(.trailing, 10)
        .frame(width: cardWidth, height: cardHeight)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 4)
    }
    
    // Green bar that fills according to the match percentage
    private var matchIndicator: some View {
        let height: CGFloat = 58
        let fraction = CGFloat(min(max(applicant.matchPercentage, 0), 100)) / 100
        
        return ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 10).fill(Color.siriusMatchBar.opacity(0.2))
            RoundedRectangle(cornerRadius: 10).fill(Color.siriusMatchBar).frame(height: height * fraction)
        }
        .frame(width: 12, height: height)
        .shadow(color: Color.black.opacity(0.25), radius: 1.5, x: 0, y: 3)
        .accessibilityLabel("\(applicant.matchPercentage) percent match")
    }
}

#Preview {
    VStack(spacing: 4) {
        EmpAplCard(applicant: EmpAplStatusController.sampleApplicants[0], isSelected: false, onSelect: {}, onSchedule: {}, onRemove: {})
        EmpAplCard(applicant: EmpAplStatusController.sampleApplicants[1], isSelected: true, onSelect: {}, onSchedule: {}, onRemove: {})
    }
    .appBg()
}
