//
//  HoveredEffect.swift
//  CleanClip
//
//  Created by lixindong on 2024/1/9.
//  Copyright © 2024 zuimeijia. All rights reserved.
//

import SwiftUI

struct SelectedEffect: ViewModifier {
    @Environment(\.isSelected)
    var isSelected
    
    @Environment(\.accentColor)
    var accentColor
    
    @Environment(\.foregroundStyle)
    var foregroundStyle
    
    var cornerRadius: CGFloat = 6
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isSelected ? accentColor : .clear)
            )
            .foreground(isSelected ? .white : foregroundStyle)
    }
}

extension View {
    func selectedEffect(cornerRadius: CGFloat = 6) -> some View {
        modifier(SelectedEffect(cornerRadius: cornerRadius))
    }
}

private struct isSelectedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct isPressedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isPressed: Bool {
        get { self[isPressedKey.self] }
        set { self[isPressedKey.self] = newValue }
    }

    var isSelected: Bool {
        get { self[isSelectedKey.self] }
        set { self[isSelectedKey.self] = newValue }
    }
}

extension View {
    func isSelected(_ selected: Bool) -> some View {
        environment(\.isSelected, selected)
    }
    
    func isPressed(_ pressed: Bool) -> some View {
        environment(\.isPressed, pressed)
    }
}

enum ButtonState {
    case normal
    case pressed
    case selected
}
