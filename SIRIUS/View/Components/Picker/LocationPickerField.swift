//
//  LocationPickerField.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/17/26.
//

import SwiftUI
import MapKit

struct LocationPickerField: View {

    let title: String
    var placeholder: String = "Search a place in the Philippines"
    @Binding var text: String
    @Binding var isVerified: Bool
    var titleColor: Color = .white
    var borderColor: Color = .siriusBorder
    var width: CGFloat = 300

    @StateObject private var search = PhilippinePlaceSearch()
    @FocusState private var focused: Bool
    @State private var isResolving = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .scaledFont(size: 13)
                .fontWeight(.medium)
                .foregroundStyle(titleColor)
                .padding(.leading, 11)

            HStack(spacing: 8) {
                Image(systemName: isVerified ? "mappin.circle.fill" : "magnifyingglass")
                    .foregroundStyle(isVerified ? Color.siriusMatchBar : Color.siriusMuted)
                    .accessibilityHidden(true)

                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.siriusTextSecondary))
                    .scaledFont(size: 14, weight: .light)
                    .foregroundStyle(Color.siriusText)
                    .focused($focused)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    .accessibilityLabel(title)
                    .onChange(of: text) { _, newValue in
                        if focused {
                            isVerified = false
                            errorMessage = nil
                            search.update(query: newValue)
                        }
                    }

                if isResolving {
                    ProgressView().controlSize(.small)
                } else if !text.isEmpty {
                    Button {
                        text = ""
                        isVerified = false
                        errorMessage = nil
                        search.clear()
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(Color.siriusMuted)
                    }
                    .accessibilityLabel("Clear location")
                }
            }
            .padding(.horizontal, 10)
            .frame(width: width)
            .frame(minHeight: 35)
            .background(Color.siriusSurface)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(borderColor, lineWidth: 1))

            if focused, !search.suggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(search.suggestions.enumerated()), id: \.offset) { index, suggestion in
                        Button { choose(suggestion) } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin")
                                    .foregroundStyle(Color.siriusNavy)
                                    .frame(width: 16)
                                    .accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(suggestion.title)
                                        .scaledFont(size: 13, weight: .medium)
                                        .foregroundStyle(Color.siriusText)
                                        .lineLimit(1)
                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle)
                                            .scaledFont(size: 11, weight: .light)
                                            .foregroundStyle(Color.siriusTextSecondary)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if index < search.suggestions.count - 1 {
                            Divider()
                        }
                    }
                }
                .frame(width: width)
                .background(Color.siriusSurface)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(borderColor, lineWidth: 1))
            }

            if let errorMessage {
                Text(errorMessage)
                    .scaledFont(size: 12, weight: .medium)
                    .foregroundStyle(Color.siriusMatchGreen)
                    .padding(.leading, 11)
            }
        }
    }

    private func choose(_ suggestion: MKLocalSearchCompletion) {
        isResolving = true
        errorMessage = nil
        Task {
            do {
                let place = try await search.resolve(suggestion)
                await MainActor.run {
                    focused = false
                    text = place.displayText
                    isVerified = true
                    search.clear()
                    isResolving = false
                }
            } catch {
                await MainActor.run {
                    isVerified = false
                    errorMessage = (error as? PhilippinePlaceError)?.errorDescription
                        ?? "Couldn't load that place. Check your connection and try again."
                    isResolving = false
                }
            }
        }
    }
}
