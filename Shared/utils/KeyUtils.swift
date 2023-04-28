//
//  KeyUtils.swift
//  Found
//
//  Created by lixindong on 2023/4/28.
//

import Foundation
import SwiftUI
import Cocoa

struct EventModifierSymbolModifier: ViewModifier {
    let modifier: EventModifiers
    let modifiers: [EventModifiers] = [.command, .control, .option, .shift]
    
    init(_ modifier: EventModifiers) {
        self.modifier = modifier
    }

    func body(content: Content) -> some View {
        let symbols: [String] = modifiers.compactMap {
            if modifier.contains($0) {
                switch $0 {
                case .command:
                    return "⌘"
                case .control:
                    return "⌃"
                case .option:
                    return "⌥"
                case .shift:
                    return "⇧"
                default:
                    return nil
                }
            }
            return nil
        }
        
        let symbolString = symbols.joined()
        
        return HStack(spacing: 0) {
            Text(symbolString)
            content
        }
    }
}

extension KeyEquivalent {
    var description: String {
        get {
            switch self.character {
            case KeyEquivalent.return.character:
                return "↩"
            default:
                return self.character.description
            }
        }
    }
}
