//
//  DateOfBirthField.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/5/26.
//

import SwiftUI

struct DateOfBirthField: View {
    let title: String
    @Binding var text: String
    var borderColor: Color = .siriusFieldBorder

    @State private var showPicker = false
    @State private var pickedDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .scaledFont(size: 13)
                .fontWeight(.medium)
                .foregroundStyle(Color.siriusInk)
                .padding(.leading, 11)

            Button {
                if let saved = Self.formatter.date(from: text) { pickedDate = saved }
                showPicker = true
            } label: {
                HStack {
                    Text(text.isEmpty ? "Select your date of birth" : text)
                        .scaledFont(size: 14, weight: .light)
                        .foregroundStyle(text.isEmpty ? Color.siriusTextSecondary : Color.siriusText)
                    Spacer()
                    Image(systemName: "calendar")
                        .scaledFont(size: 16)
                        .foregroundStyle(Color.gray)
                }
                .padding(10)
                .frame(width: 300)
                .frame(minHeight: 35)
                .background(Color.siriusFieldFill)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(borderColor, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(title)
        }
        .sheet(isPresented: $showPicker) {
            NavigationStack {
                VStack {
                    DatePicker("", selection: $pickedDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                    Spacer()
                }
                .navigationTitle("Date of Birth")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showPicker = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            text = Self.formatter.string(from: pickedDate)
                            showPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
