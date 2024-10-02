//
//  PinnedEnvironment.swift
//  CleanClip
//
//  Created by lixindong on 2024/1/15.
//  Copyright © 2024 zuimeijia. All rights reserved.
//

import SwiftUI

/// accentColor
struct AccentColorKey: EnvironmentKey {
    static let defaultValue: Color = .accentColor
}

extension EnvironmentValues {
    var accentColor: Color {
        get { self[AccentColorKey.self] }
        set { self[AccentColorKey.self] = newValue }
    }
}

extension View {
    func accentColor(color: Color) -> some View {
        environment(\.accentColor, color)
    }
}

/// hoveredColor
struct HoveredColorKey: EnvironmentKey {
    static let defaultValue: Color = Color.gray.opacity(0.1)
}

extension EnvironmentValues {
    var hoveredColor: Color {
        get { self[HoveredColorKey.self] }
        set { self[HoveredColorKey.self] = newValue }
    }
}

extension View {
    func hoveredColor(color: Color) -> some View {
        environment(\.hoveredColor, color)
    }
}

/// foregroundStyle
struct ForegroundStyleKey: EnvironmentKey {
    static let defaultValue: Color = .primary
}

extension EnvironmentValues {
    var foregroundStyle: Color {
        get { self[ForegroundStyleKey.self] }
        set { self[ForegroundStyleKey.self] = newValue }
    }
}

extension View {
    func foreground(_ color: Color) -> some View {
        foregroundStyle(color)
            .environment(\.foregroundStyle, color)
    }
}
