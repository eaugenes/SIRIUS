//
//  NavigationButton.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/10/26.
//

import SwiftUI

struct NavigationButton<Destination: View>: View {
    let title: String
    let destination: Destination
    let isBackgroundFill: Bool

    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}
