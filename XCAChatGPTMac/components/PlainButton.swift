//
//  PlainButton.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/16.
//

import SwiftUI

struct PlainButton: View, Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shortcut: KeyEquivalent?
    let modifiers: EventModifiers
    let action: () -> Void


    init(icon: String = "",
         label: String = "",
         backgroundColor: Color = .transparent,
         cornerRadius: CGFloat = 6,
         shortcut: KeyEquivalent? = nil,
         modifiers: EventModifiers = [],
         action: @escaping () -> Void) {
        self.action = action
        self.icon = icon
        self.label = label
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shortcut = shortcut
        self.modifiers = modifiers
    }
    
    var body: some View {
        let btn = Button(action: action) {
            HStack {
                if !icon.isEmpty {
                    Image(systemName: icon)
                }
                if !label.isEmpty {
                    Text(label)
                }
            }
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
        }
            .buttonStyle(RoundedButtonStyle(cornerRadius: 6))
        if let shortcut = shortcut {
            btn.keyboardShortcut(shortcut, modifiers: modifiers)
        } else {
            btn
        }
    }
}


struct PlainButton_Previews: PreviewProvider {
    static var previews: some View {
        PlainButton {
            
        }
    }
}
