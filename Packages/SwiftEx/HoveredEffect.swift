//
//  HoveredEffect.swift
//  CleanClip
//
//  Created by lixindong on 2024/1/9.
//  Copyright © 2024 zuimeijia. All rights reserved.
//

import SwiftUI

struct HoveredEffect: ViewModifier {
    @State private var hovered = false
    @Environment(\.hoveredColor) var hoveredColor
    @Environment(\.accentColor) var accentColor
    @Environment(\.foregroundStyle) var foregroundStyle

    var style: HoveredStyle = .normal
    var cornerRadius: CGFloat = 6
    var animate: Bool = true
    func body(content: Content) -> some View {
        let targetColor = colorOf(style)
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(targetColor.opacity(hovered ? 1 : 0))
            )
            .foreground(hovered ? .white : foregroundStyle)
            .onHover { hovered in
                if animate {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.hovered = hovered
                    }
                } else {
                    self.hovered = hovered
                }
            }
    }
    
    func colorOf(_ style: HoveredStyle) -> Color {
        var targetColor: Color
        switch style {
        case .normal:
            targetColor = hoveredColor
        case .accent:
            targetColor = accentColor
        case .custom(let color):
            targetColor = color
        }
        return targetColor
    }
}

enum HoveredStyle: Equatable {
    case normal, accent, custom(color: Color)
}

extension View {
    func hoveredEffect(_ style: HoveredStyle? = nil, cornerRadius: CGFloat = 6, animate: Bool = true) -> some View {
        if let style {
            modifier(HoveredEffect(style: style, cornerRadius: cornerRadius, animate: animate))
        } else {
            modifier(HoveredEffect(cornerRadius: cornerRadius, animate: animate))
        }
    }
}
