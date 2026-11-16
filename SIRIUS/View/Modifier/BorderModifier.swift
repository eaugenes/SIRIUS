//
//  BorderModifier.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

struct BorderModifier: Shape{
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        for edge in edges {
            switch edge {
            case .top:
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            case .bottom:
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            case .leading:
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            case .trailing:
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            }
        }
        return path
    }
}

extension View {
    func visibleEdges(_ edges: [Edge], color: Color, width: CGFloat = 1) -> some View {
        overlay(
            BorderModifier(edges: edges)
                .stroke(color, lineWidth: width)
        )
    }
}
