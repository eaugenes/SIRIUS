//
//  AppStepper.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/6/26.
//

import SwiftUI

// "−  1  +" stepper used for Years of Experience and Maximum Hire
struct AppStepper: View {
    let title: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...50
    var borderColor: Color = .gray
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 13))
                .fontWeight(.medium)
                .foregroundStyle(Color.black)
                .padding(2)
            
            HStack(spacing: 0) {
                stepButton(symbol: "minus", isEnabled: value > range.lowerBound) {
                    value -= 1
                }
                
                Text("\(value)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                
                stepButton(symbol: "plus", isEnabled: value < range.upperBound) {
                    value += 1
                }
            }
            .frame(width: 300, height: 35)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
        }
    }
    
    private func stepButton(symbol: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.black.opacity(isEnabled ? 1 : 0.3))
                .frame(width: 44, height: 35)
                .background(Color.siriusFill)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    AppStepper(title: "Years of Experience", value: .constant(1))
        .appBg()
}
