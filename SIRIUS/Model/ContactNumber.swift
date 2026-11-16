//
//  ContactNumber.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import Foundation
import SwiftUI

enum ContactNumber {
    static let length = 11
    static let errorMessage = "Contact number must be exactly 11 digits (e.g., 09171234567)."

    static func isValid(_ text: String) -> Bool {
        text.count == length && text.allSatisfy { $0.isASCII && $0.isNumber }
    }

    static func cleaned(_ text: String) -> String {
        String(text.filter { $0.isASCII && $0.isNumber }.prefix(length))
    }

    static func binding(_ text: Binding<String>) -> Binding<String> {
        Binding(
            get: { text.wrappedValue },
            set: { text.wrappedValue = cleaned($0) }
        )
    }
}
